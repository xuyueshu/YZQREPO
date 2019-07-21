package com.sunmnet.spider.utils;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class FileOperatorUtil {
    //读取出字符串
    /*public static String readFromFile(String filePath, String charset) throws Exception {
        File file = new File(filePath);
        FileInputStream fis = new FileInputStream(file);
        InputStreamReader isr=new InputStreamReader(fis);
        BufferedReader br=new BufferedReader(isr);
        StringBuilder builder=new StringBuilder();
        String temp=null;
        int lineCount=0;
        while ((temp=br.readLine())!=null){
            if(lineCount>0){
                builder.append("\n");

            }
            builder.append(temp);
            lineCount++;
        }
        br.close();
        return  builder.toString();

    }*/
    /*读取出集合*/
    public static List<String> getSeedsListFromFile(String filePath, String charset) throws Exception {
        File file = new File(filePath);
        FileInputStream fis = new FileInputStream(file);
        InputStreamReader isr=new InputStreamReader(fis);
        BufferedReader br=new BufferedReader(isr);
        List<String> seedsList=new ArrayList<String>();
        String temp=null;
        while ((temp=br.readLine())!=null){
            temp=temp.trim();
            if(temp!=null){
                seedsList.add(temp);
            }
        }
        br.close();
        return  seedsList;
    }
/*
    public static void main(String[] args) throws Exception {
        String filePath="seeds.txt";
        String charset="UTF-8";
        //String result=FileOperatorUtil.readFromFile(filePath,charset);
        List<String> result=FileOperatorUtil.getSeedsListFromFile(filePath,charset);
        System.out.println(result);

    }
*/

}
