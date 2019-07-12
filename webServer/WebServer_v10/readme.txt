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

8:修改HttpResponse的setENtity方法，在该方法中除了允许外界设置要响应正文实体文件外，还需要根据文件的长度以及
 该文件名对应的后缀设置响应头Content-Length，Content-Type，而通过文件后缀获取Content-Type操作主要依靠步骤4中：
 在HttpContext中提供的方法：getContentType（）




本版本改動：
利用Tomcat安裝的目錄下 conf/web.xml文件，將所有的介質類型
解析出來並使用。


1.在當前項目目錄下新建一個目錄：conf
2。將tomcat中web.xml文件拷貝到該目錄
3.重構HttpContext類中initMapping方法，通過解析web.xml
來初始化Content-Type頭對應的值。




本版本改动：
支持用户提交表单数据

我们日常上网常见的操作如： 登陆，注册等，都是在页面上填写好数据后，
浏览器提交一个表单给服务端。而提交表单有两种形式：GET，POST
GET形式成为地址栏形式提交，数据会包含在地址栏中“？”右侧POST
形式提交数据，数据会被包含在请求的消息正文中。

对此，服务端在解析请求时，要考虑用户可能会传递数据的情况
并对数据进行解析，一边在处理业务的过程中获取这些数据。

1.在webapps/myweb/下新建一个注册页面：reg.html
    在该页面中了解<form>表单的应用。
    
    2.重构HttpRequest解析操作，先完成GET形式提交数据的解析


















