
v2
1.熟悉HTTP协议相关内容

2：在core包中建立用于处理客户端请求的类：ClientHandler

3：修改webServer,当一个客户端连接后启动一个线程来处理该
     客户端请求。
4.:在ClientHandler中定义一个方法，测试按行读取客户端发送
    过来的数据，每行以CRLF结尾为标志。利用该方法可以解析
   请求中的请求行和消息头部分。
   
   
   
   
   
   
  v3 本版本改动：（建请求对象）
   1.在ClientHandler中开始第一步工作，解析请求，由于请求内容
   比较多，所以设计一个类TttpRequest,并用该类的每一个实例表示一个
   客户端发过来的具体请求。
   
   2. 在HttpRequest的构造方法中完成解析请求的工作，而解析一个
   请求分为三步骤：
               解析请求行， 解析消息头， 解析消息正文
               
               
               
               
               
               
               
               
 v4 本版本改动：
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
  
  
  
  
  
  
  v5本次改动：
  完成解析请求中的消息头工作。
  
  1. 在HttpRequest中定义一个属性。
     Map<String,String> headers
     使用该属性保存请求中的每个消息头，其中key：消息头的名字
     value对应的值。
     
 2.    完成parseHeaders方法，继续通过readLine方法读取若干行
        内容 ，每一行应当是一个消息头。因为HttpRequest的构造方法
        中先调用的仙子阿parseRequest方法，已经读取了该请求的第一行
        字符串（请求行内容），所以剩下的若干行内容都是消息头。 
  
  
  
  
  
  
  
  
  
v6  本次改动：
  
 响应客户端锁请求的页面
 
 在ClientHandler中，当根据request获取客户端请求到的资源路径
 找到webapps下对应的资源，然后向客户发送一个标准的响应
  
  
  
  
  
  
  
  
  
 v7 本版本改动：
  
  对响应操作进行重构（建 响应对象）
  
  1：在http包中定义一个类：HttpResponse。使用该类的每一个实例
  表示要给客户端发送的一个具体响应内容
  
  2.在HttpResponse中定义flush方法，用于将当前对象表示的响应内容
     发送给客户端。
  flush方法中要完成三个步骤：
     发送状态行，发送响应头，发送响应正文
  
  3.将ClientHandler中原发送响应的代码移动到HttpResponse中
     定义的相关方法中。取而代之的是调用flush方法完成响应工作。
     
     
     
     
     
     
     
   v8  本版本改动：
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
      操作所对应的死循环打开了。仙子阿可以一直接收客户端请求了
     
  
  
  
  
 

v9版本改动：
HttpResponse在发送响应头时，对应的资源类型现在是写死值Content-Type:text/html
这样做会导致当前页面含有其它资源时（图片，样式，脚本）浏览器在请求这些资源得到的类型都是text/html
会导致浏览器无法正确的理解其请求的这些资源，那么在现实该页面时就会出现一些不正常的情况，对此，我们
应当根据客户端请求的不同资源返回正确的响应头Content-Type所对应的值

1：首先我们要在HttpContent中在定义一个静态的属性：
  Map<String,String>MimeMapping
  其中的Key为请求资源的后缀名，value为对应的Content-Type的值。
  例如：
  html所对应的为text/html
  png对应的为image/png
  css对应的为text/css
  具体不同的介质类型对应的值w3c官网有定义。或可以借鉴Tomcat的配置文件（后面的版本会在使用）

2：创建一个私有的静态方法：initMimeMapping，用来初始化截至类型的映射

3：在静态块中调用初始化方法，对截至映射做初始化操作

4：提供一个静态方法，用于通过资源的后缀名来获取到对应的介质类型Content-Type的值。


5:重构HttpResponse的发送响应头的操作，现在的操作为固定的发送两个响应头：Content-Type与Content-Length。
 我们将发送响应头改为可以进行设置的，这样将来想给客户发送不同的响应头时就可以进行添加了
 对此，我们在HttpResponse中添加一个新的属性：
 Map<String,String>headers
 其中key：响应头的名字 value为响应头对应的值

6：修改HttpResponse中sendheaders方法的逻辑，改为遍历的属性headers这个Map，有几个响应头就发送几个

7：在HttpRespons中添加一个方法：putHeader，允许外界对当前响应对象设置要发送的响应头。

8:修改HttpResponse的setENtity方法，在该方法中除了允许外界设置要响应正文实体文件外，还需要根据文件的长度以及
 该文件名对应的后缀设置响应头Content-Length，Content-Type，而通过文件后缀获取Content-Type操作主要依靠步骤4中：
 在HttpContext中提供的方法：getContentType（）






v10
版本改动：
HttpResponse在发送响应头时，对应的资源类型现在是写死值Content-Type:text/html
这样做会导致当前页面含有其它资源时（图片，样式，脚本）浏览器在请求这些资源得到的类型都是text/html
会导致浏览器无法正确的理解其请求的这些资源，那么在现实该页面时就会出现一些不正常的情况，对此，我们
应当根据客户端请求的不同资源返回正确的响应头Content-Type所对应的值

1：首先我们要在HttpContent中在定义一个静态的属性：
  Map<String,String>MimeMapping
  其中的Key为请求资源的后缀名，value为对应的Content-Type的值。
  例如：
  html所对应的为text/html
  png对应的为image/png
  css对应的为text/css
  具体不同的介质类型对应的值w3c官网有定义。或可以借鉴Tomcat的配置文件（后面的版本会在使用）

2：创建一个私有的静态方法：initMimeMapping，用来初始化截至类型的映射

3：在静态块中调用初始化方法，对截至映射做初始化操作

4：提供一个静态方法，用于通过资源的后缀名来获取到对应的介质类型Content-Type的值。


5:重构HttpResponse的发送响应头的操作，现在的操作为固定的发送两个响应头：Content-Type与Content-Length。
 我们将发送响应头改为可以进行设置的，这样将来想给客户发送不同的响应头时就可以进行添加了
 对此，我们在HttpResponse中添加一个新的属性：
 Map<String,String>headers
 其中key：响应头的名字 value为响应头对应的值

6：修改HttpResponse中sendheaders方法的逻辑，改为遍历的属性headers这个Map，有几个响应头就发送几个

7：在HttpRespons中添加一个方法：putHeader，允许外界对当前响应对象设置要发送的响应头。

8:修改HttpResponse的setENtity方法，在该方法中除了允许外界设置要响应正文实体文件外，还需要

joui98ot878    754kowf】//	M度以及
 该文件名对应的后缀设置响应头Content-Length，Content-Type，而通过文件后缀获取Content-Type操作主要依靠步骤4中：
 在HttpContext中提供的方法：getContentType（）




本版本改動：
利用Tomcat安裝的目錄下 conf/web.xml文件，將所有的介質類型





``		
解析出來並使用。      






v11
1.在當前項目目錄下新建一個目錄：conf
將tomcat中web.xml文件拷貝到該目錄
2.重構HttpContext類中initMapping方法，通過解析web.xml
來初始化Content-Type頭對應的值。
  2 重构HttpRequest解析操作，先完成GET形式提交数据的解析。
  2.1定义三个属性：requestURI，queryString，parameters
  2.2 定义一个解析url内容的方法：parseUrl
  2.3 在parseRequestLine方法中，当解析出来url后调用parseUrl这个方法
  对url进一步解析
  将请求部分和参数部分进行解析并设置到对应的这三个属性上。
  
  3.修改ClientHandler处理请求的逻辑，从原来直接通过请求对象
  根据url进行判断，改进为根据requestURI判断请求内容。并
  进行处理请求的操作。 

 4.修改请求是否为处理业务，若是则实例化对应的Servlet来处理，对此
  我们要在ClientHandler中添加一个新的分支，就是根据请求判断是否为请求
  业务，然后处理。
  
  5.创建新的包：servlet，并在该包下新建一个处理注册业务的类
  RegServlet，并完成Service方法，该方法用来处理注册。
  
  6.在webapps/myweb/下新建一个页面：reg_success.html
  当注册成功后就会跳转该页面
  
  
  
 v12 本版本改动：
 完成用户登陆功能
 
 流程：
	 1.用户请求登陆该页面
	 2.在该页面输入登陆信息（用户名，密码）
	3.点击登陆按钮
	4.<form>表单提交请求到：/myweb/login
	5.ClientHandler添加新的分支，判断请求是否为登陆业务
	6.实例化LoginServlet并调用service方法处理登陆
	7.根据登录结果向用户反馈登录成功或失败的页面。

实现：
	1.在webapps/myweb/下新建登录页面login.html，
	登录成功页面：login_success.html
	登录失败页面：login——fail.html
	
	2.在servlets包中新建处理登录业务的类：LoginServlet
	并实现service方法
	在该方法中首先通过request获取用户表单中输入的用户名及密码
	然后通过RandomAccessFile读取user.dat文件。比如每条记录
	的用户名及密码，若找到对应并且用户输入一致，则
	设置response响应登录成功页面，若密码不一致，活着没有这个用户
	则设置response响应登录失败页面。
	
	3.在ClientHandler判断请求处理业务处再添加一个分支，判断请求
	是否为处理登录，若是，则实例化LoginServlet并调用service方法。

注：登录页面中的<form>表单action属性值指定为“login”





v13
本版本改动；
解决空请求问题
HTTP协议中有所说明，允许客户端发送空请求，实际上就是客户
端在连接服务端后，没有发送内容。这时如果我们开始解析请求
内容（从请求行开始解析会出现下标越界）会出现异常。
对此我们应当支持忽略空请求的操作。

1.在http包中定义一个类：EmptyRequestException自定义一个
“空请求”异常

2。在HttpRequest的解析请求行parseRequestLine方法中，一但
发现是一个空请求时，则对外抛出异常，直到给ClientHandler
3.ClientHandler要多一个catch处理，专门捕获空请求问题
。 这样，当实例化HttpRequest过程抛出该异常后，ClientHandler
就不再对该请求做后续任何处理，等同于忽略空请求操作。


v14
本版本改动
	解决浏览器通过GET形式请求传递数据的中文问题。
	
	由于GET请求时地址栏传参方式，那么所有参数会拼接到url中一起提交过来。
	e而url部分最终会出现在请求的请求行中。
	而HTTp协议要求，请求行，这些部分对应的字符集
	
	
	我们不能直接传递中文
	
	
	浏览器的做法是将中文按照对应的字符集（通常是utf-8）将该字符
	转换为一组字节，然后每个字节以2位16进制的字符串形式表示，并在前面添加一个%
	
	如：请求行：GET /myweb/login?username=%E6%B8%B8%E5%BF%97%E5%BC%BA&password=980043299 HTTP/1.1
	
	            经过：URLDecoder.decode(url,"utf-8")后，得到的字符串样子为：
	            
	            /myweb/login?username=游志强&password=980043299
	
	java中提供了一个解析URL中%xx%内容的API：URLDecoder
	
	在HttpRequest中，进一步解析URL方法：parseURL中使用URLDecoder对
	url解码，从而得到正确的字符。




v15
	本版本改动
	代码重构
		1.HttpResponse中还有一些冗余代码，需要提炼并复用代码。
		
		2.HttpRequest与HttpResponse中都有使用到CR，LF。那么要在HttpContext中定义这两个常量，然后复用。
		
		java编写程序时，保持一个思想：能重用的就不重写。
	原则：
			同类中重复代码抽方法
			不同类中重复代码抽超类
			不同类相同方法，但方法内容不同时，抽超类并定义抽象方法
		
		
		
		
v16 
本版本改动
（<a href=“”></a>   超链接）
当页面表单提交的数据包含用户的隐私信息，或者有上传附件操作时，
这个form表单提交的提交形式已定要使用post形式。
post形式提交的数据不会被拼接在地址栏中，而是包含在请求的消息正文中，
并且该请求会有两个消息头：Content-Type和Content-length说明该
请求包含消息正文并且正文内容类型。
先后实现post提交的支持，我们需要根据请求的消息头得知是否含有
消息正文，并且根据类型对消息正文解析。		

1.将注册登录的form表单提交方式改为post
2.当一个post形式提交的表单到服务端后，服务端在解析该请求时，
要根据消息头Content-Type与Content-length对消息正文进行解析。
如果Content-Type的值为：application/x-www-form-urlencode
说明这是一个form表单提交上来的用户输入信息。内容是字符串，
格式就是原GET请求提交时地址栏“？”右侧内容

完成解析请求中的消息正文部分：HttpRequest的parseContent方法
3.将参数部分的代码重用，为此提出一个方法：parseParameters
然后在parseUrl以及parseContent中对参数部分的解析都采用调该
方法完成。




V17
本版本改动：
将webServer中使用的一些数据改为可以进行配置的。
比如：服务端使用的端口，响应使用的协议版本，解析参数时使用的字符集。

1.在项目目录的conf中再定义一个xml文档：server.xml。
再该文档中将服务端需要的数据定义再这里，

2.再core包中添加一个类：ServerContext
将服务端需要的数据定义为对应的静态属性
定义一个静态的初始化方法，加载server.xml并解析，然后对这些
静态属性初始化。

3.再ServerContext中定义一个静态块，调用该方法。

4.在使用这些数据的代码中，从原有的直接写死的形式，改变为引用ServerContext
对应的属性。

