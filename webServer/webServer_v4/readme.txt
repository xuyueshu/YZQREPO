1.熟悉HTTP协议相关内容

2：在core包中建立用于处理客户端请求的类：ClientHandler

3：修改webServer,当一个客户端连接后启动一个线程来处理该
     客户端请求。
4.:在ClientHandler中定义一个方法，测试按行读取客户端发送
    过来的数据，每行以CRLF结尾为标志。利用该方法可以解析
   请求中的请求行和消息头部分。
   
   
   
   
   本版本改动：
   1.在ClientHandler中开始第一步工作，解析请求，由于请求内容
   比较多，素以设计一个类TttpRequest,并用该类的每一个实例表示一个
   客户端发过来的具体请求。
   
   2. 在HttpRequest的构造方法中完成解析请求的工作，而解析一个
   请求分为三步骤：
               解析请求行， 解析消息头， 解析消息正文
               
               
               
               
  v4本版本改动：
  1.在项目目录下创建一个目录：webapps
  对于服务端容器而言，每个我们所谓的网站，包括该网站的
  页面，素材，业务逻辑等组成称为一个web应用。
  webpps目录可以存放所有的web应用，用于给用户响应不同
  应用对应的服务，而webapps下应当用每一个子目录作为一个
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
               