package com.webserver.http;
/**
 * 空请求
 * 当HttpRequest初始化过程中（解析过程）发现该请求实际上是一个空请求时
 * 会抛出异常
 * @author soft01
 *
 */
public class EmptyRequestException extends Exception {
	private static  final long serialVersionUID=1L;

	public EmptyRequestException() {
		super();
		
	}

	public EmptyRequestException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
		
	}

	public EmptyRequestException(String message, Throwable cause) {
		super(message, cause);
		
	}

	public EmptyRequestException(String message) {
		super(message);
		
	}

	public EmptyRequestException(Throwable cause) {
		super(cause);
		
	}
	

}
