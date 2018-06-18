cd c:\Filings_Comparison\Data
cd c:\Filings_Comparison\Data
date /t  
time /t  
@echo starting script  

git pull https://github.com/NYCDOB/Filings_Comparison.git gh-pages

del Antenna_Merge.csv
del Curbcut_Merge.csv
del Fence_Merge.csv
del Plumbing_Merge.csv
del Scaffold_Merge.csv
del Shed_Merge.csv
del Sign_Merge.csv
del Sprinkler_Merge.csv
del Standpipe_Merge.csv
del Elevators_Merge.csv
del Electrical_Merge.csv



git add "Antenna_Merge.csv"
git add "Curbcut_Merge.csv"
git add "Fence_Merge.csv"
git add "Plumbing_Merge.csv"
git add "Scaffold_Merge.csv"
git add "Shed_Merge.csv"
git add "Sign_Merge.csv"
git add "Sprinkler_Merge.csv"
git add "Standpipe_Merge.csv"
git add "Elevators_Merge.csv"
git add "Electrical_Merge.csv"
git commit -m "delete from script" 

@echo running R script
 c:\"Program Files"\R\R-3.4.2\bin\Rscript.exe script.R

@echo local repo commit  


git branch gh-pages  
git checkout -f gh-pages 
git status  


git add "Antenna_Merge.csv"
git add "Curbcut_Merge.csv"
git add "Fence_Merge.csv"
git add "Plumbing_Merge.csv"
git add "Scaffold_Merge.csv"
git add "Shed_Merge.csv"
git add "Sign_Merge.csv"
git add "Sprinkler_Merge.csv"
git add "Standpipe_Merge.csv"
git add "Elevators_Merge.csv"
git add "Electrical_Merge.csv"
git commit -m "commit from script"  
git push https://username:password@github.com/NYCDOB/Filings_Comparison.git gh-pages

date /t  
time /t   
@echo job done  
pause
