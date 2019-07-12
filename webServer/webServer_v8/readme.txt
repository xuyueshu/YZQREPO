1.熟悉HTTP协议相关内容

2：在core包中建立用于处理客户端请求的类：ClientHandler

3：修改webServer,当一个客户端连接后启动一个线程来处理该
     客户端请求。
4.:在ClientHandler中定义一个方法，测试按行读取客户端发送
    过来的数据，每行以CRLF结尾为标志。利用该方法可以解析
   请求中的请求行和消息头部分。
   
   
   
   
   
   
   本版本改动：（建请求对象）
   1.在ClientHandler中开始第一步工作，解析请求，由于请求内容
   比较多，所以设计一个类TttpRequest,并用该类的每一个实例表示一个
   客户端发过来的具体请求。
   
   2. 在HttpRequest的构造方法中完成解析请求的工作，而解析一个
   请求分为三步骤：
               解析请求行， 解析消息头， 解析消息正文
               
               
               
               
               
               
               
               
  本版本改动：
  1.在项目目录下创建一个目录：webapps
  对于服务端容器而言，每个我们所谓的网站，包括该网站的
  页面，素材，业务逻辑等组成称为一个web应用。
  webpps目录可以存放所有的web应用，用于给用户响应不同
  应用对应的服务，而webpps下应当用每一个子目录作为一个
  具体应用保存相关内容。
  
  2.在webapps创建一个子目录：myweb
  
  3.在myweb下创建一个页面 index.html
  
  4.在ClientHandler中处理请求，根据HttpRequest获取用户请求
  中的资源路径，该路径是一个相对路径。
  http：localhost:8088/myweb/index.html
  那么我们在请求中请求行部分得到的url内容就是：
  /myweb/index.html
  而该路径相对哪里，这由我们位呢webServer指定即可，由于我们将
  所有的web应用素材都放在了webapps目录中，所以我们可以指定
  相对目录就是相对webapps目录即可。
  那么当我们得到请求路径后从对应的webapps下应该可以 找到
  myweb目录并得到里面的index.html页面
  
  5.得到请求路径后从webspps目录中训导对应该资源，并根据结果分别
  打桩
  
  
  
  
  
  
  本次改动：
  完成解析请求中的消息头工作。
  
  1. 在HttpRequest中定义一个属性。
     Map<String,String> headers
     使用该属性保存请求中的每个消息头，其中key：消息头的名字
     value对应的值。
     
 2.    完成parseHeaders方法，继续通过readLine方法读取若干行
        内容 ，每一行应当是一个消息头。因为HttpRequest的构造方法
        中先调用的parseRequest方法，已经读取了该请求的第一行
        字符串（请求行内容），所以剩下的若干行内容都是消息头。 
  
  
  
  
  
  
  
  
  
  本次改动：
  
 响应客户端锁请求的页面
 
 在ClientHandler中，当根据request获取客户端请求到的资源路径
 找到webapps下对应的资源，然后向客户发送一个标准的响应
  
  
  
  
  
  
  
  
  
  本版本改动：
  
  对响应操作进行重构（建 响应对象）
  
  1：在http包中定义一个类：HttpResponse。使用该类的每一个实例
  表示要给客户端发送的一个具体响应内容
  
  2.在HttpResponse中定义flush方法，用于将当前对象表示的响应内容
     发送给客户端。
  flush方法中要完成三个步骤：
     发送状态行，发送响应头，发送响应正文
  
  3.将ClientHandler中原发送响应的代码移动到HttpResponse中
     定义的相关方法中。取而代之的是调用flush方法完成响应工作。
     
     
     
     
     
     
     
     本版本改动：
     添加对404页面的响应工作。当用户请求的路径无效时，响应404页面。
     
     由于要响应404状态代码，为此，HttpResponse中发送状态行时就不
     能只发送200了。所以，状态代码也要变为可以进行设置的。并且不同的
     状态代码也有对应的状态描述。状态描述在Http协议中有默认值，为此，
     我们可以创建一个Map将每个状态代码与对应的描述关联起来。这样我们
     设置了状态代码就可以自动从Map中找到对应的描述。
     
     1.在HttpResponse中添加两个新的属性：
     int  statusCode    状态代码
     int  statusReason  状态描述
     
     2.在Http包中单独定义一个类：HttpContext
     使用这个类来定义有关Http协议内容的定义信息。比如状态
     代码和对应的状态描述
     对此，在该类中定义一个静态私有属性：
     Map<Integer,String>statusCode_Reason_Mapping
     key:状态代码  value：对应的状态描述
     这个Map可以允许我们根据状态代码找到对应的状态描述
     
     3.在HttpContext下添加初始化该Map的方法，并将Http协议中
     代码状态和状态描述设置进去。
     
     4.在HttpContext的静态块中调用初始化Map的方法
     
     5.在HttpContext中定义一个静态方法用于根据状态代码获取对应
     状态描述。
     
     6.在HttpResponse中对状态代码和状态描述添加get，set方法
     并且在setStatusCode（）方法中再添加一行代码，设置状态
     描述并设置到对应属性--状态描述上。
     
     7. 404页面时服务端没有找到客户端请求资源时回复的页面。那么
     无论客户端请求的是服务端哪个web应用中的资源，只要不存在都
     应当回复该页面，所以该页面是个通用页面。为此我们不将该页面
     放在webapps/myweb应用中。而是造webapps
     下新建一个目录root，将通用资源都放在这里。
     对此我们再root目录下新建一个页面：404.html
     
     8. 在ClientHandler中添加分支，当请求对应的资源没有找到时
     首先 设置response的状态代码为404，并且设置对应的响应实体
     文件为webapps/root/404.html
     9.最终将404页面响应给客户端。
  
 10.都测试完后，可以将webserver主类中start方法里接收客户端的
      操作所对应的死循环打开了。现在可以一直接收客户端请求了
     
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
               