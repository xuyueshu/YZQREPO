package com.sunmnet.spider.download;


import com.sunmnet.spider.utils.StaticValue;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;

/*负责url网址代码的下载*/
public class WebPageDownloadUtil {
    public static BufferedReader getBR(String url,String charset) throws Exception{
        URL urlObj =new URL(url);
        InputStream is=urlObj.openStream();
        InputStreamReader isr=new InputStreamReader(is,charset);
        BufferedReader br=new BufferedReader(isr);
        return br;
    }
    public static String getHtmlSourceByUrlAPI(String url,String charset) throws Exception {
        BufferedReader br= getBR(url,charset);
        StringBuilder builder=new StringBuilder();
        String temp = null;
        int lineCount=0;
        while ((temp=br.readLine())!=null){
            if(lineCount>0){
                builder.append(StaticValue.NEXT_LINE);
            }
            lineCount++;
            builder.append(temp);
        }
        br.close();
        return builder.toString();

    }

    public static void main(String[] args) throws Exception {
        String url="http://news.youth.cn/gn/";
       // String url="https://www.baidu.com/";

        //String url="https://www.jianshu.com/";

        /*String charset="gb2312";
        String content=WebPageDownloadUtil.getHtmlSourceByUrlAPI(url,charset);
        System.out.println(content);*/
        //System.out.println(CharsetDetectorUtil.getCharset(url));
        String charset=CharsetDetectorUtil.getCharset(url);
        System.out.println(charset);
    }
}
