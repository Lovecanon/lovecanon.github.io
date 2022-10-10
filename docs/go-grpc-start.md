
## 环境安装
```bash
# 安装protoc命令
# https://github.com/protocolbuffers/protobuf/releases 网页下载适合当前机器的protoc，并加入到PATH环境变量中

# 安装go依赖工具
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

# 安装go依赖
go get google.golang.org/grpc@v1.49.0
go get google.golang.org/protobuf@v1.28.0
```

## 小试牛刀
### 目录结构
```bash
$ tree  newgrpc/
newgrpc/
├── client
│   └── client.go # 客户端
├── profile
│   ├── profile_grpc.pb.go # protoc自动生成
│   ├── profile.pb.go      # protoc自动生成
│   └── profile.proto
└── server
    ├── handler
    │   └── profile.go # profile.proto定义的服务具体实现
    └── server.go # 服务端
```

### 源代码[go-grpc-start](https://github.com/lovecanon/go-grpc-start)

```go
// newgrpc/server/server.go
package main

import (
	"fmt"
	"log"
	"net"

	"go-grpc-start/newgrpc/profile"
	"go-grpc-start/newgrpc/server/handler"

	"google.golang.org/grpc"
)

func main() {
	fmt.Println("Start server...")

	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", 9000))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	profile.RegisterProfileServiceServer(s, &handler.Profile{})

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %s", err)
	}
}
```

```go
// newgrpc/server/handler/profile.go
package handler

import (
	"go-grpc-start/newgrpc/profile"
	"log"
	"golang.org/x/net/context"
)

type Profile struct {
	// 老版本的可以不用添加该成员，新版本必须添加
	profile.UnimplementedProfileServiceServer
}

func (s *Profile) Create(ctx context.Context, req *profile.CreateRequest) (*profile.CreateResponse, error) {
	log.Printf("Receive message body from client: [%d]%s", req.GetId(), req.GetName())
	return &profile.CreateResponse{Message: "Profile Created!"}, nil
}
```

```proto
syntax = "proto3";
package profile;

option go_package = "./profile";

// The profile service definition.
service ProfileService {
  // create a profile
  rpc Create (CreateRequest) returns (CreateResponse) {}
}

// The request message containing the user's name, is_verified, id
message CreateRequest {
  string name = 1;
  bool is_verified = 2;
  int32 id = 3;
}

// The response message containing the profile
message CreateResponse {
  string message = 1;
}
```

```go
// newgrpc/client/client.go
package main

import (
	"go-grpc-start/newgrpc/profile"
	"log"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

func main() {
	var conn *grpc.ClientConn
	conn, err := grpc.Dial(":9000", grpc.WithInsecure())
	if err != nil {
		log.Fatalf("connect server, err: %s", err)
	}
	defer conn.Close()

	c := profile.NewProfileServiceClient(conn)

	createReq := profile.CreateRequest{Name: "***Jack***", Id: 21, IsVerified: true}
	response, err := c.Create(context.Background(), &createReq)
	if err != nil {
		log.Fatalf("Error Profile Create: %s", err)
	}
	log.Printf("Response from server: %s", response.Message)
}
```

### 编译
```bash
# 生成pb和grpc文件
cd newgrpc/
protoc --proto_path=profile --go_out=profile --go_opt=paths=source_relative --go-grpc_out=profile --go-grpc_opt=paths=source_relative profile.proto

# 或者使用
protoc --proto_path=profile --go_out=. --go-grpc_out=. profile.proto
```

### 编译后文件输出目录
```bash
$ cd newgrpc
$ protoc --proto_path=profile --go_out=profile/b --go-grpc_out=profile/a profile.proto
profile/a/: No such file or directory
$ mkdir profile/a
$ mkdir profile/b

$ protoc --proto_path=profile --go_out=profile/b --go-grpc_out=profile/a profile.proto
$ tree profile/
profile
├── a
│   └── profile
│       └── profile_grpc.pb.go
├── b
│   └── profile
│       └── profile.pb.go
└── profile.proto

$ rm -rf profile/a
$ rm -rf profile/b
```

添加`--go_opt=paths=source_relative`选项，看看区别：

```bash
$ protoc --proto_path=profile --go_out=profile/b --go_opt=paths=source_relative --go-grpc_out=profile/a --go-grpc_opt=paths=source_relative profile.proto
profile/a/: No such file or directory
$ mkdir profile/a
$ mkdir profile/b

$ protoc --proto_path=profile --go_out=profile/b --go_opt=paths=source_relative --go-grpc_out=profile/a --go-grpc_opt=paths=source_relative profile.proto
$ tree profile/
profile/
├── a
│   └── profile_grpc.pb.go
├── b
│   └── profile.pb.go
└── profile.proto
```

结论：`--go_out=. --go_opt=paths=source_relative`选项，会将编译后的文件，放到执行命令时所在目录。**不会**放到`option go_package = "./profile";`，即：profile/XX.pb.go目录下。

```
# 编译后的文件被输出到profile目录，即：和profile.proto同在一个目录
protoc --proto_path=profile --go_out=. --go-grpc_out=. profile.proto

# 若修改profile.proto文件中的：option go_package = "./profile111";
# 则编译后输出到profile111目录下，该目录和profile同级
```


## proto文件编写：注意事项

假设我编写的proto文件如下：
```proto
syntax = "proto3";
package profile;

option go_package = "profile";
```

编译proto文件，报错：
```bash
$ protoc --proto_path=profile --go_out=. profile.proto
protoc-gen-go: invalid Go import path "profile" for "profile.proto"

The import path must contain at least one forward slash ('/') character.

See https://developers.google.com/protocol-buffers/docs/reference/go-generated#package for more information.

--go_out: protoc-gen-go: Plugin failed with status code 1.
```

修复：go_package添加斜杠
```
syntax = "proto3";
package profile;

option go_package = "./profile";
```

### 指定输出文件目录及包名
```proto
syntax = "proto3";
package profile;

// 将编译后的pb文件放到 proto/profile 目录下，并且package名称为：profile2
// 等价于：
// # --go_opt=M{proto文件}={编译后目录}
// $ protoc --proto_path=profile --go_out=. --go_opt=Mprofile.proto=proto/profile profile.proto
option go_package = "proto/profile;profile2";
```

再添加一些东西，有趣的事情发生了，
```bash
# 正常编译
$ protoc --proto_path=profile --go_out=a profile.proto

# 那么，如果我想再通过命令来控制pb文件的输出路径呢？指定 --go_out=a的值，
# 表示，将pb文件放到a目录下
$ protoc --proto_path=profile --go_out=a profile.proto
a/: No such file or directory
$ mkdir a

# 注意，此时还是在newgrpc目录下
$ protoc --proto_path=profile --go_out=a profile.proto
$ tree a
a
└── proto
    └── profile
        └── profile.pb.go
```

结论：**命令行 `--go_out`可以控制pb文件的输出路径，proto文件中的`option go_package=""`也可以控制pb文件的输出路径。**。不过第二种方式官方不建议使用。

> For both the go_package option and the M flag, the value may include an explicit package name separated from the import path by a semicolon. For example: "example.com/protos/foo;package_name". This usage is discouraged since the package name will be derived by default from the import path in a reasonable manner.

## 测试老版本`protoc-gen-go`
老版本和新版本的区别：
1. 老版本使用：`github.com/golang/protobuf/protoc-gen-go`，而新版本使用：`google.golang.org/protobuf/cmd/protoc-gen-go`
1. 老版本只生成一个`XX.pb.go`文件，该文件包括：protobuf编码和服务定义；而新版本将这两个功能拆分成两个文件，`XX.pb.go`为protobuf编码，`XX_grpc.pb.go`是服务的定义。这两个文件的生成目录分别对应命令行中的`--go_out`和`--go-grpc_out`两个选项
1. pb.go文件生成命令不同

具体区别参考：[v1.20-generated-code](https://github.com/protocolbuffers/protobuf-go/releases/tag/v1.20.0#v1.20-generated-code)

```bash
# 虽然提示被废弃，但还是写入到go.mod中
$ go get github.com/golang/protobuf
go: downloading github.com/golang/protobuf v1.5.2
go: module github.com/golang/protobuf is deprecated: Use the "google.golang.org/protobuf" module instead.
go get: added github.com/golang/protobuf v1.5.2

# 编译protobuf/protoc-gen-go
# 我居然无法进入：cd ~/go/pkg/mod/github.com/golang/protobuf@v1.5.2/protoc-gen-go 目录，不知道为啥！
$ cd /tmp/ && git clone https://github.com/golang/protobuf.git && cd protobuf/protoc-gen-go && go build
# 将编译后的二进制文件移动到环境变量中
$ mv protoc-gen-go ~/go/bin/
```

