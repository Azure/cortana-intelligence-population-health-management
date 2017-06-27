# Population Health Management for Healthcare - A Cortana Intelligence Solution

## The state of Health Care
According to the [Centers for Medicaid and Medicare Services](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/nationalhealthexpenddata/nationalhealthaccountshistorical.html), U.S. health care spending reached $3.2 trillion -- or $9,990 per person -- in 2015, accounting for 17.8 percent of the Gross Domestic Product. One-third of this health care expenditure comes from hospital inpatient care. With spending [projected](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/medicare-provider-charge-data/downloads/publiccomments.pdf) to reach $4.8 trillion in 2021, health care has become the [top concern](http://big.assets.huffingtonpost.com/tabsHPTrumpIssues20170320.pdf) for Americans, even surpassing the economy. Concerted efforts are being made to reduce spending. The recent shift in government [payment models](https://www.healthcatalyst.com/hospital-transitioning-fee-for-service-value-based-reimbursements) from fee-for-service to pay-for-value is aimed specifically at reducing the government’s spending on health care and curtailing the growing budget deficits. Under this model, disease prevention and management is rewarded while poor outcomes are penalized. This shift from fee-for-service payments to value-based care is transforming the US health care industry and forcing providers to provide better care at a lower cost, impacting their bottom line. 


## What is Population Health Management

Population Health Management is an important tool that is increasingly being used by health care providers to manage and control the escalating costs. The crux of Population Health Management is to use data to improve health outcomes. Tracking, monitoring and bench marking are the three bastions of Population Health Management, aimed at improving clinical and health outcomes while managing and reducing cost. 

## Ingredients for a successful Population Health Management solution
 
A successful population health management initiative requires establishing a repository that can collect data from multiple sources in any and all formats, whether it be structured, semi-structured or unstructured. Furthermore, the repository needs to be able to integrate the disparate data sources, with a fast time-to-action to flexibly meet ever-evolving healthcare analytics needs. By analyzing the patient population to gain insight into its socioeconomic constitution, demographics, and overall medical condition across geospatial regions, health care providers can better understand the quality of care being provided and identify areas for improvement and cost savings. 

The Azure Data Lake Store & Analytics is one such technology that has all the capabilities required to build a population health management repository. The [Azure Data Lake Store (ADLS)](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-overview) allows users to store data of any size, shape and speed, while [Azure Data Lake Analytics (ADLA)](https://docs.microsoft.com/en-us/azure/data-lake-analytics/data-lake-analytics-overview) has the capability to conduct data processing, advanced analytics, and machine learning modeling with high scalability in a cost-effective way. Using U-SQL, R, Python and/or .NET, it allows users to run massively parallel data transformation and processing over petabytes of data. (Joseph Sirosh, the Corporate Vice President of Microsoft Data Group, wrote an excellent [blog post: The Intelligent Data Lake](https://azure.microsoft.com/en-us/blog/the-intelligent-data-lake/?v=17.23h).) As an alternative choice of advanced analytics engine, [Spark on HDInsight](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-overview) is also a top selection. Besides the native language support to Scala and Java for performing data analytics such as [MLlib](https://spark.apache.org/mllib/), it also has interface to support R ([SparkR](https://spark.apache.org/docs/latest/sparkr.html)) and Python ([PySpark](https://spark.apache.org/docs/0.9.0/python-programming-guide.html)). 

There are several decision points when choosing between ADLA or Spark on HDInsight as the analytics tool. One key advantage of ADLA is that it provides the users more SaaS like user experience. It is optimized to seamlessly work with ADLS - providing the highest level of performance, throughput, and parallelization for the big data workload. It provides dynamic scaling, which dynamically provisions resources when needed, while winds down resources automatically when the job completes. On the other hand, the merit of Spark on HDInsight lies in its flexibility and strong community support.  Note that ADLA is built solely on the Azure platform, while Spark is open source. Last but not least, ADLA only costs money while the query job is executing, but HDInsight spark cluster always incurs a cost as long as the cluster is launched. 

## What's in this solution

In this solution guide, we present two use cases under the umbrella of Population Health Management:  

- [Live Population Health Report with Hospital Length of Stay prediction](Azure%20Data%20Lake/README.md)
- [Patient-Specific Readmission Prediction and Intervention for Health Care](Spark/README.md)

With different input data schema, the former use case showcases the usage of ADLA with U-SQL and R, while the latter use case makes usage of HDInsight Spark 2.0 with PySpark as the analytics engine. 
 


