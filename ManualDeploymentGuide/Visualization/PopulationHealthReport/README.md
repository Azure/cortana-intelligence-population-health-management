# Population Health Report 

A population health report lets the health care providers get an insight into the population they server and get actionable intelligence. In this solution we have created some reports based on data described above. These are just examples of the insights and tracking we can do with this kind of data. Some of the reports created are below.  

<style>
.column-left{
  float: left;
  width: 33%;
  text-align: left;
}
.column-center{
  display: inline-block;
  width: 33%;
  text-align: center;
}
.column-right{
  float: right;
  width: 33%;
  text-align: right;
}
</style>

#### This section will have three columns
<div class="column-left">
**1** one  
**2** two  
</div>
<div class="column-center">
**3** three  
**4** four  
**5** five  
**6** six  
</div>
<div class="column-right">
**7** seven  
**8** eight  
**9** nine  
</div>

<style>
.column-left{
  float: left;
  width: 50%;
  text-align: left;
}
.column-right{
  float: right;
  width: 50%;
  text-align: right;
}
</style>

#### This section will have two columns

<div style="float:left; width:50%;">
Left  <!-- Set Div As your requirement -->
</div>
<div style="float:left; width:50%;">
Right  <!-- Set Div As your requirement -->
</div>


Patient Stats 
In this report we create a snapshot of patient population. We look at Total Admits by Age, Gender, Race, Income, Admit Type and Payer Type. Emergency visits can cost a lot. We also look at Total Admits and Total charge by Payer. We can compare different hospitals and over time.
![Solution Diagram Picture](https://raw.githubusercontent.com/)


Health Stats
In this report we create a snapshot of medical condition of patient population. We look at Total Admits by Primary Diagnosis, MDC (Major Diagnostic Category) and most frequent Procedures performed. We also look at Total Admits for chronic conditions by Age and Gender.

Length of stay report
In the length of stay report we look at the Average Length of stay by Payer Type, Gender, Age and Procedures. We also look at Average Total charge by Average Length of stay variation by Diagnosis (DXMCCS). We look at the performance of the length of stay model by comparing the true length of stay to predicted length of stay for historic data.

Cost report
In the Cost Report, we look at the Total Charge , Total cost of chronic disease and what proportion it is of Total Charges, Total cost of Readmittance and what proportion it is of Total Charges. We look at Total Charges by Payer and Gender as well as Total charge per day by Payer type. We also look at % of admits contributing to Total cost.

Intervention Profile
In this report we look at Most Readmitted Conditions, Readmittance by Payer and Age. To reduce readmision you get an insight into who to target and intervene to prevent, reduce readmittance.

Readmittance Tracking
In this report we track Readmittance rate for certain conditions for different hospitals. There is also a metric file that we use for this visualisation thaat contains the goal to be met by a hospital regarding their readmit rate. By monitoring how they are doing every month, they can by proactive about measures to meet their target.

Hot Spots
In this report, we at geographic distribution of some chronic conditions. By monitoring the progression by location over time, we can identify hot spots for surge in certain conditions. 
