#!/bin/awk -f
###命令 awk -f gampaign_model.sh CAMPAIGN_model.txt
BEGIN{FS=":";low1=300;low2=400;low3=500
    OFS="\t"
    print "\t\t***CAMPAIGN 1998 CONTRIBUTIONS***\n"
    print "---------------------------------------------------------------------------------\n"
    print " Name\t\t\tPHone\t\t\tJan |\tFeb |\tMAR |\tTotal Donated"
    print "---------------------------------------------------------------------------------\n"
    }
  
{tot=$3+$4+$5}
{Ttot+=tot}
{print $1,"\t"$2"\t\t"$3" \t"$4" \t"$5" \t"tot}
{avg=Ttot/12}
{high1=(high1>$3)?high1:$3}
{high2=(high1>$4)?high1:$4}
{high3=(high1>$5)?high1:$5}
{max12=(high1>high2)?high1:high2}
{max23=(high2>high3)?high2:high3}
{Max=(max12>max23)?max12:max23}
{low1=(low1<$3)?low1:$3}
{low2=(low1<$4)?low1:$4}
{low3=(low1<$5)?low1:$5}
{min12=(low1<low2)?low1:low2}
{min23=(low2<low3)?low2:low3}
{Min=(min12<min23)?min12:min23}
  
END{
    print "-----------------------------------------------------------------------------------"
    print"\t\tSUMMARY"
    print "-----------------------------------------------------------------------------------"
    printf "The campan received atotal of $";printf Ttot; print " for this quarter"
    printf "average donation for the 12 contributors was $"; printf avg ;print"."
    printf "The highest contribution was $";printf Max;print "."
    printf "The lowest contribution was $";printf Min;print "."
}