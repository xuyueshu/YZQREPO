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

















