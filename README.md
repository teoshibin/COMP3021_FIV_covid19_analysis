# Covid 19 Data Visualization and Analysis

![Active Cases World Map GIF](./Output/GIF/qa5.gif)

Covid19 dataset visualization using R. Generated charts, interactive html charts and GIFs are presented in the visualization & analysis section.

## Dataset
- [Covid-19 Global Dataset](https://www.kaggle.com/josephassaker/covid19-global-dataset)
- [COVID-19 World Vaccination Progress](https://www.kaggle.com/gpreda/covid-world-vaccination-progress)

## Visualization & Analysis
- [Analysis Markdown](./ANALYSIS.md)

## Implementation

### Folder Structure

```
.
└── covid19_analysis/
    ├── Data/
    ├── Function/
    ├── Output/
    │   ├── HTML/
    │   ├── GIF/
    │   ├── PNG/
    │   └── Screenshot/
    ├── covid19_analysis.Rproj
    ├── main.Rmd
    ├── ANALYSIS.md
    ├── README.md
    └── ...
```

`Data` Input dataset   
`Function` Auxiliary functions   
`Output` Contains different type of generated outputs   
`covid19_analysis.Rproj` Main R project file   
`main.Rmd` Main markdown script   
`ANALYSIS.md` Quick presentation of all generated outputs   
`README.md` Read me   

### Reproducibility
`renv.lock` dependency file is available within the project, simply run `renv::restore()` to install specified packages.

### Notebook
- [R markdown HTML](./main.html) - [preview](http://htmlpreview.github.io/?https://github.com/teoshibin/COMP3021_FIV_covid19_analysis/blob/main/main.html)
- [R mardown PDF (Less Interactive)](#)