---
layout: post
title: Python - some questions?
tags: [pipe, socket, deque, socketpair]
description: "简介"
image: '/images/posts/2019/overview_hero.jpg'
---



### 来回调用问题  

想修改job的时候何不直接调用`job._modify()`方法，还要大费周折调用`scheduler.modify_job()`然后通过scheduler在调用`job._modify()`??
    
可能原因猜测：在Job对象中保留Scheduler对象的引用，需要时调用scheduler的`modify_job`方法，`scheduler.modify_job()`会在修改(`_modify`)job之前之后做一些额外的处理。

```python
# schedulers.base:BaseScheduler

class BaseScheduler(metaclass=ABCMeta):
    def modify_job(self, job_id, jobstore=None, **changes):

        with self._jobstores_lock:
            job, jobstore = self._lookup_job(job_id, jobstore)
            job._modify(**changes)  # 之前之后会对scheduler的一些状态进行改变
            if jobstore:
                self._lookup_jobstore(jobstore).update_job(job)
        return job


# job:Job
class Job:

    def __init__(self, scheduler, id=None, **kwargs):
        super().__init__()
        self._scheduler = scheduler
        self._jobstore_alias = None
        self._modify(id=id or uuid4().hex, **kwargs)
    
    def modify(self, **changes):
        
        # 
        self._scheduler.modify_job(self.id, self._jobstore_alias, **changes)
        return self

    def _modify(self, **changes):
        approved = {}

        if 'id' in changes:
            pass
```


### How do pipes in Python work?

Generally there are two kinds of pipes:
* anonymous pipes
* named pipes(FIFO)

Anonymous pipes exist solely within processes and are usually used in combination with forks.

The concept of pipes and pipelines was introduced by Douglas McIlroy, one of the authors of the early command shells, after he noticed that much of the time they were processing the output of one program as the input to another. Ken Thompson added the concept of pipes to the UNIX operating system in 1973. Pipelines have later been ported to other operating systems like DOS, OS/2 and Microsoft Windows as well.

Unix or Linux without pipes is unthinkable, or at least, pipelines are a very important part of Unix and Linux applications. Small elements are put together by using pipes. Processes are chained together by their standard streams, i.e. the output of one process is used as the input of another process. To chain processes like this, so-called anonymous pipes are used.

The following example illustrates the case, in which one process (child process) writes to the pipe and another process (the parent process) reads from this pipe.
```python
import os, time, sys
pipe_name = 'pipe_test'
 
def child( ):
    pipeout = os.open(pipe_name, os.O_WRONLY)
    counter = 0
    while True:
        time.sleep(1)
        os.write(pipeout, 'Number %03d\n' % counter)
        counter = (counter+1) % 5
 
def parent( ):
    pipein = open(pipe_name, 'r')
    while True:
        line = pipein.readline()[:-1]
        print 'Parent %d got "%s" at %s' % (os.getpid(), line, time.time( ))
 
if not os.path.exists(pipe_name):
    os.mkfifo(pipe_name)  # 创建named pipe

pid = os.fork()
if pid != 0:  # parent
    parent()
else:       
    child()
```

**Another Answer：**
A pipe is basically a block of memory in the kernel, a buffer that is read/written by some processes. The advantage of using pipes is that it has 2 file descriptors associated with it, and thus sharing data between 2 processes is as simple as reading/writing to a file.
```python
import os
import sys

rfd, wfd = os.pipe()
process_id = os.fork()

if process_id:
    # parent process, parent read
    os.close(wfd)
    r = os.fdopen(rfd)
    # read from pip
    text = r.read()
    print('parent read:{}'.format(text))
    r.close()
    sys.exit(0)
else:
    os.close(rfd)
    w = os.fdopen(wfd, 'w')
    w.write('what the f**k')
    w.close()
    sys.exit(0)
```
参考：[how do pipes in python work -- quora.com](https://www.quora.com/How-do-pipes-in-Python-work)


### socket.socketpair()

> def socketpair(family=AF_INET, type=SOCK_STREAM, proto=0):

socketpair()创建一对相互连通、匿名的socket，参数指定了socket的domain、type、protocol等。
* 管道仅存在于特定主机中，它们指的是虚拟文件之间的缓冲，或连接该主机内进程的输出/输入。管道内没有包(package)的概念。
* 套接字使用IPv4或IPv6打包通信;通信可以扩展到localhost之外。请注意，套接字的不同端点可以共享相同的IP地址;但是，他们必须侦听不同的TCP / UDP端口才能这样做。

BTW, you can use netcat or socat to join a socket to a pipe.


```python
import socket
import os

parent_sock, child_sock = socket.socketpair()
pid = os.fork()

if pid:  # parent
    child_sock.close()
    parent_sock.sendall(b'ping')
    response = parent_sock.recv(1024)
    print('parent_sock got:{}'.format(response))
    parent_sock.close()
else:  # child
    parent_sock.close()
    data = child_sock.recv(1024)
    print('child_sock got:{}'.format(data))
    child_sock.sendall(b'pong')
    child_sock.close()
```

参考：[What's the difference between pipes and sockets?](https://stackoverflow.com/questions/18568089/whats-the-difference-between-pipes-and-sockets)

























