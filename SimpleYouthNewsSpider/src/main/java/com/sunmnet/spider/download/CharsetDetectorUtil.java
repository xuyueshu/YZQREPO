package com.sunmnet.spider.download;
/*
解决读取html字符编码问题，给定一个url，
获取其html的编码的工具类
*/

import com.sunmnet.spider.utils.StaticValue;

import java.io.BufferedReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.sql.SQLOutput;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CharsetDetectorUtil {
    /*用head获取charset*/
    public static String getCharset(String url) throws Exception {
        String finalCharset=null;
        URL webUrl=new URL(url);
        URLConnection urlConnection =webUrl.openConnection();
        Map<String,List<String>> map=urlConnection.getHeaderFields();
       /* System.out.println(map);*/
        List<String> kvList=map.get("content-type");
        if(kvList!=null&&!kvList.isEmpty()){
            String charsetKV=kvList.get(0);
            if (charsetKV.contains(";")){
                String[] charsetKVList=charsetKV.split(";");
                for (String kv:charsetKVList){
                    String[] ele=kv.split("=");
                    if(ele.length==2){
                        if (ele[0].equals("charset")){
                            finalCharset=ele[1].trim();
                        }

                    }
                }
            }
        }

        if(finalCharset==null){
            BufferedReader br =WebPageDownloadUtil.getBR(url,StaticValue.DEFAULT_ENCODING);
            String temp=null;
            while ((temp=br.readLine())!=null){
                System.out.println(temp);
                String charsetValue=getCharsetValue4Line(temp);
                if (charsetValue!=null){
                    finalCharset=charsetValue;
                    break;
                }
                temp=temp.toLowerCase();
                if(temp.contains("</head>")){
                    break;
                }


            }

        }

        return finalCharset;
    }
    public static String getCharsetValue4Line(String line){
        String regex="charset=(.+?)\"?\\s?/?>";
        Pattern pattern=Pattern.compile(regex);
        Matcher matcher=pattern.matcher(line);
        String charsetValue=null;
        if(matcher.find()){
            charsetValue=matcher.group(1);
        }
        return charsetValue;
    }



}
