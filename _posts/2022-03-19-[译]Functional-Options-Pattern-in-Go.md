# [译]Functional Options Pattern in Go
原文链接：[Functional Options Pattern in Go](https://halls-of-valhalla.org/beta/articles/functional-options-pattern-in-go,54/)

Go语言的开发者会遇到这样一个问题：试图让函数的参数变得可选。它的一个常见的使用场景是，创建对象时可以使用默认配置实现开箱即用，同时也能够提供一些更细节配置。例如：创建一个数据库连接对象，你可以使用默认的`timeout`，也可以自己配置。

在其他语言中，这种可选参数非常容易实现。在类C语言中，你可以让一个函数拥有不同的版本，每个版本拥有不同数量的参数。在类PHP语言中，你可以设置函数参数的默认值。但在Golang中这些方法都行不通。那么，该如何创建这种函数，根据用户需求进行灵活配置。

下面有几种不同的方式，但不是很优雅，要么需要在服务代码中做很多额外验证，要么开发者使用时需要传递很多他们不需要，甚至不想关心的参数。

我首先介绍几种不同的实现方式，看一看为什么这些实现不是最优的，最后我再说一说比较优雅的方式：函数式选项模式（The Functional Options Pattern）。

## 实现一：没有实现
我们看一个例子，我们定义了一个`StuffClient`接口和实现该接口的结构体`stuffClient`，它包含一个方法和两个配置（`timeout`和`retries`）：

```go
type StuffClient interface {
    DoStuff() error
}
type stuffClient struct {
    conn    Connection
    timeout int
    retries int
}
```
`stuffClient`结构体是私有的，我们可以提供一个构造函数：
```go
func NewStuffClient(conn Connection, timeout, retries int) StuffClient {
    return &stuffClient{
        conn:    conn,
        timeout: timeout,
        retries: retries,
    }
}
```
Hmm，当我们每次调用`NewStuffClient`函数时，都必须传入`timeout`和`retries`参数。很多时候，我们只想用默认配置。但是在Golang中又不允许定义有不同参数个数的多个`NewStuffClient`函数版本，否则我们将会遇到编译错误：`NewStuffClient redeclared in this block`。

我们可以创建另一个不同名的构造函数：
```go
func NewStuffClient(conn Connection) StuffClient {
    return &stuffClient{
        conn:    conn,
        timeout: DEFAULT_TIMEOUT,
        retries: DEFAULT_RETRIES,
    }
}
// 创建另一个不同名的构造函数
func NewStuffClientWithOptions(conn Connection, timeout, retries int) StuffClient {
    return &stuffClient{
        conn:    conn,
        timeout: timeout,
        retries: retries,
    }
}
```

## 实现二：增加config结构体`StuffClientOptions`
看起来有点丑，我们可以传入一个`配置对象`让代码变得好看一些：
```go
// 将配置放到配置对象
type StuffClientOptions struct {
    Retries int
    Timeout int
}
func NewStuffClient(conn Connection, options StuffClientOptions) StuffClient {
    return &stuffClient{
        conn:    conn,
        timeout: options.Timeout,
        retries: options.Retries,
    }
}
```
但这看起来也不是很优雅，因为不管我们要不要单独指定配置，我们都需要创建一个`StuffClientOptions`结构体对象，传入构造函数中。如果客户端传入一个空的`StuffClientOptions`结构体对象，因为没有自动填充默认值，我们需要做额外的判断决定是否使用默认值。或者我们可以传入一个`DefaultStuffClientOptions`变量，也不好, 因为它如果被一个地方修改后，其他地方都会出现意想不到的问题。

## 实现三：The Functional Options Pattern
那么，解决的办法是什么？函数式选项模式（The Functional Options Pattern）利用go语言对闭包的支持可以很好的解决面临的窘境。我们保留上面定义的`StuffClientOptions`结构体，但我们还增加了点东西：
```go
type StuffClientOption func(*StuffClientOptions)
type StuffClientOptions struct {
    Retries int
    Timeout int
}
func WithRetries(r int) StuffClientOption {
    return func(o *StuffClientOptions) {
        o.Retries = r
    }
}
func WithTimeout(t int) StuffClientOption {
    return func(o *StuffClientOptions) {
        o.Timeout = t
    }
}
```
非常清晰，有没有？？？发生了甚么事？首先，我们定义一个供`StuffClient`使用的`StuffClientOptions`结构体，其次，我们还定义了一个`StuffClientOption`（注意，单数形式），它是是个函数类型，接收一个`StuffClientOptions`结构体指针作为参数。此外，我们还定义了一系列的函数`WithRetries`、`WithTimeout`，它们返回一个闭包。魔法开始：

```go
var defaultStuffClientOptions = StuffClientOptions{
    Retries: 3,
    Timeout: 2,
}
func NewStuffClient(conn Connection, opts ...StuffClientOption) StuffClient {
    options := defaultStuffClientOptions
    for _, o := range opts {
        o(&options)
    }
    return &stuffClient{
        conn:    conn,
        timeout: options.Timeout,
        retries: options.Retries,
    }
}
```
较之前，我们的代码做了哪些改变？我们定义了一个内部变量`defaultStuffClientOptions`，它包含了我们配置的默认值。我们还调整了构造函数的参数，使其变成可变参数（Variadic Parameter）。然后，我们遍历`StuffClientOption`类型的参数，并且将返回的闭包函数应用到`options`变量中。可以看到，调用闭包函数时，会修改默认配置中的成员值。

现在我们可以通过下面方法调用：
```go
x := NewStuffClient(Connection{})
fmt.Println(x) // 输出：&{{} 2 3}

x = NewStuffClient(
    Connection{},
    WithRetries(1),
)
fmt.Println(x) // 输出：&{{} 2 1}

x = NewStuffClient(
    Connection{},
    WithRetries(1),
    WithTimeout(1),
)
fmt.Println(x) // prints &{{} 1 1}
```

看起来不错！！！这种做法还有一个好处：我们随时可以新增新的配置，但开发者无需修改自己的代码。

整体程序现在是这样：
```go
var defaultStuffClientOptions = StuffClientOptions{
    Retries: 3,
    Timeout: 2,
}
type StuffClientOption func(*StuffClientOptions)
type StuffClientOptions struct {
    Retries int
    Timeout int
}
func WithRetries(r int) StuffClientOption {
    return func(o *StuffClientOptions) {
        o.Retries = r
    }
}
func WithTimeout(t int) StuffClientOption {
    return func(o *StuffClientOptions) {
        o.Timeout = t
    }
}
type StuffClient interface {
    DoStuff() error
}
type stuffClient struct {
    conn    Connection
    timeout int
    retries int
}
type Connection struct {}
func NewStuffClient(conn Connection, opts ...StuffClientOption) StuffClient {
    options := defaultStuffClientOptions
    for _, o := range opts {
        o(&options)
    }
        return &stuffClient{
            conn:    conn,
            timeout: options.Timeout,
            retries: options.Retries,
        }
}
func (c stuffClient) DoStuff() error {
    return nil
}
```
你可以在[Go Playground](https://play.golang.org/p/VcWqWcAEyz)自己验证一哈～

如果将`StuffClientOptions`结构体移除程序将变得更简单，直接修改`defaultStuffClient`中的默认值：
```go
var defaultStuffClient = stuffClient{
    retries: 3,
    timeout: 2,
}
type StuffClientOption func(*stuffClient)
func WithRetries(r int) StuffClientOption {
    return func(o *stuffClient) {
        o.retries = r
    }
}
func WithTimeout(t int) StuffClientOption {
    return func(o *stuffClient) {
        o.timeout = t
    }
}
type StuffClient interface {
    DoStuff() error
}
type stuffClient struct {
    conn    Connection
    timeout int
    retries int
}
type Connection struct{}
func NewStuffClient(conn Connection, opts ...StuffClientOption) StuffClient {
    client := defaultStuffClient
    for _, o := range opts {
        o(&client)
    }
    
    client.conn = conn
    return client
}
func (c stuffClient) DoStuff() error {
    return nil
}
```
[Go Playground](https://play.golang.org/p/Z5P5Om4KDL)，运行看看！！这个例子中，我们直接将`WithXXX`的参数应用到`defaultStuffClient`默认客户端对象中，看样子并不需要额外的config结构体`StuffClientOptions`。其实不然，多数情况下我们依旧需要使用config结构体。举个栗子，如果你的构造函数使用配置选项来执行一些操作, 并不需要把它们存储到结构中, 或将其传递到其他地方。显然，config结构体的实现更加通用。

最后，感谢[Rob Pike](https://commandcenter.blogspot.de/2014/01/self-referential-functions-and-design.html)和[Dave Cheney](https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis)推广这种设计模式。

