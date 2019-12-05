import re
import sys



def dGenerate():


    print ("Script name: %s" % str(sys.argv[0]))
    registry_name = str(sys.argv[1])
    file_repo_name = str(sys.argv[2])

    registry_name = str(sys.argv[1])
    file_repo_name = str(sys.argv[2])
    no_retention = str(sys.argv[3])
    #mejkrqmc3hlyc_elc_elx3-cms-dev.ref_lst
    ref_file =  registry_name + "_" +  file_repo_name + ".ref_lst"  
    out_file =  registry_name + "_" +  file_repo_name + ".del_lst"


    #$registry_name"_"$file_repo_name".sorted_lst"
    print ref_file

    #Read the file which is the output of az repository list
    with open( ref_file ) as my_file:
        build_tag_raw = my_file.readlines()

    build_tag_clean = [x.replace('\n', '') for x in build_tag_raw ]

    def stringSplitByNumbers(x):
        r = re.compile('(\d+)')
        l = r.split(x)
        return [int(y) if y.isdigit() else y for y in l]

    build_tag_sorted = sorted(build_tag_clean, key = stringSplitByNumbers)

    #Leave n number of images and delete the rest, execute the loop only if the exusting number of images is more than that of ret
    #Write sorted listed for delete list
    if len(build_tag_sorted) > int(no_retention):
        print "Number of images in the repo: " + str(len(build_tag_sorted)) +  " is greater than that configured the retentiomn policy: " + no_retention + ", creatin the list to cleanup cleaning up."  
        outF = open( out_file , "w")
        for x in range(len(build_tag_sorted) - int(no_retention)):  
            #print build_tag_sorted[x]
            outF.write(build_tag_sorted[x])
            outF.write("\n")
        #print len(build_tag_sorted)
        outF.close()
    else:
        print "Number of images in the repo: " + str(len(build_tag_sorted)) +  " is lesser than that configured the retentiomn policy: " + no_retention + ", we are safe."   


if __name__ == '__main__':
    dGenerate() 
    #mejkrqmc3hlyc elc_elx3-cms-dev 10

