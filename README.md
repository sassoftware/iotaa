# IOTAA Repo for Technical Papers


## Overview

 The purpose is to facilitate sharing code and data needed to customers from published technical papers from the IOTAA team. A link to ALL Technical papers published within SAS can be found at [Technical Papers | SAS Support](https://support.sas.com/en/technical-papers.html)

**Technical Papers linked to this repository:**

- [Time-Frequency Analysis  Methods and Applications in SAS®](https://support.sas.com/content/dam/SAS/support/en/technical-papers/time-frequency-analysis-methods-and-applications-in-sas.pdf)
- [Fault Identification Using Dynamic Bayesian Networks](https://support.sas.com/content/dam/SAS/support/en/technical-papers/fault-identification-using-dynamic-bayesian-networks.pdf)
- [Nominal Variables Dimension Reduction Using SAS](https://support.sas.com/content/dam/SAS/support/en/technical-papers/nominal-variables-dimension-reduction-using-sas.pdf)

### List of Examples
| File/Folder | Application |
| ------ | ------ |
|Fault Identification Using Dynamic Bayesian Networks/TE.sas| Fault identification using dynamic Bayesian networks for Tennessee Eastman chemical plant process.|
|Fault Identification Using Dynamic Bayesian Networks/two_tank.sas| Fault identification using dynamic Bayesian networks for two-tank data.|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Music Decomposition with EMD and HHT| Instrument-Based Music Decomposition|
Signal Processing Methods and Applications in SAS/Examples and Datasets/Feature Extraction from EEG using EMD| Analyzing EEG Signals|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Queen Bee Piping Example 1|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Queen Bee Piping Example 2|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Logistic Regression on Soybean Data | Preprocessing Soybean Data using PROC NOMINALDR for Logistic Regression|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Neural Network on Molecular Biology Data | Preprocessing Molecular Biology Data using PROC NOMINALDR for Neural Network|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Gaussian Process Classification on Mushroom Data | Preprocessing Mushroom Data using PROC NOMINALDR for Gaussian Process Classification|

### List of Datasets required for Examples
| File/Folder | Application |
| ------ | ------ |
|Fault Identification Using Dynamic Bayesian Networks/TE| A folder containing data for TE.sas. Generated using PROC IML code based on code from [Ricker (2002).](#te)|
|Fault Identification Using Dynamic Bayesian Networks/two_tank| A folder containing data for two_tank.sas. Adapted from [Lerner et al. (2000).](#tank)|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Feature Extraction from EEG using EMD/eeg.sas7bdat| Dataset used for EEG feature extraction.
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Music Decomposition with EMD and HHT| Three audio files used for the music decomposition example. The files are bass.wav, flute.wav, combo.wav| 
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Three sas datasets needed to run the Queen bee piping detection examples. The datasets are fs.sas7bdat, spectral_adj.sas7bdat, and spectral_data.sas7bdat|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Logistic Regression on Soybean Data | A folder containing Soybean datasets for PROC NOMINALDR and PROC LOGISTIC: soybean-large.data for training and soybean-large.test for testing|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Neural Network on Molecular Biology Data | A folder containing Molecular Biology Datasets for PROC NOMINALDR and PROC NNET: molecularBiologyTrain.csv for training and molecularBiologyTest.csv for testing|
|Nominal Variables' Dimension Reduction Using SAS/PROC NOMINALDR with Gaussian Process Classification on Mushroom Data | A folder containing Mushroom Datasets for PROC NOMINALDR and PROC GPCLASS: mushroomTrain.csv for training and mushroomTest.csv for testing|


### Installation
All code requires software that runs SAS IML and other procs in SAS such as SAS Viya. For more information please see [SAS.com](https://www.sas.com/en_us/home.html)

### What's New

No updates as of 2/13/24

## Contributing

**Required**. If you are part of IOTAA and would like to contribute to this repository, please email laura.gonzalez@sas.com to be added as a collaborator. 

> We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project. 



## License

> This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources

SAS Institute Inc. (2017). Base SAS 9.4 Procedures Guide. 7th ed. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/9.4_3.5/docsets/proc/content/proc.pdf?locale=en#nameddest=n0pio2crltpr35n1ny010zrfbvc9. 

SAS Institute Inc. (2018). SAS/IML 15.1 User's Guide. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/9.4_3.4/docsets/imlug/content/imlug.pdf?locale=en. 

SAS Institute Inc. (2023). Working with Charts and Tables. Retrieved from https://go.documentation.sas.com/api/collections/espcdc/v_048/docsets/espvisualize/content/espvisualize.pdf?locale=en#nameddest=n1afzvhtws0s23n19wy0elwhergw. 

SAS Institute Inc. (2024a). DYNBNET Procedure. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/v_048/docsets/casml/content/casml.pdf?locale=en#nameddest=casml_dynbnet_toc

SAS Institute Inc. (2024b). SAS Event Stream Processing: Overview. Retrieved from https://go.documentation.sas.com/api/collections/espcdc/v_048/docsets/espov/content/espov.pdf?locale=en#nameddest=home.

SAS Institute Inc. (2024c). SAS IML: Language Reference. Retrieved from  https://pubshelpcenter.unx.sas.com/test/doc/en/pgmsascdc/v_052/casimllang/titlepage.htm. 

SAS Institute Inc. (2024d). Using Dynamic Bayesian Networks. Retrieved from https://go.documentation.sas.com/api/collections/espcdc/v_048/docsets/espan/content/espan.pdf?locale=en#nameddest=n1a24zmowg07opn1ul03ulh6g23c. 

SAS Institute Inc. (2025a). GPCLASS Procedure. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/v_069/docsets/casml/content/casml.pdf?locale=it#nameddest=casml_gpclass_toc.

SAS Institute Inc. (2025b). LOGISTIC Procedure. Retrieved from https://go.documentation.sas.com/doc/en/pgmsascdc/v_068/statug/statug_logistic_toc.htm.

SAS Institute Inc. (2025c). NNET Procedure. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/v_069/docsets/casml/content/casml.pdf?locale=it#nameddest=casml_nnet_toc.

SAS Institute Inc. (2025d). NOMINALDR Procedure. Retrieved from https://go.documentation.sas.com/api/collections/pgmsascdc/v_069/docsets/casml/content/casml.pdf?locale=it#nameddest=casml_nominaldr_toc.

SAS Institute Inc. (2025e). STDIZE Procedure. Retrieved from https://go.documentation.sas.com/doc/en/pgmsascdc/v_068/statug/statug_stdize_toc.htm.


## <a name="ref"> </a> References for Fault Identification Using Dynamic Bayesian Networks

<a name="tank"> </a> Lerner, U., Parr, R., Koller, D., & Biswas, G. (2000). "Bayesian Fault Detection and Diagnosis in Dynamic Systems." In Proceedings of the Seventeenth National Conference on Artificial Intelligence and Twelfth Conference on Innovative Applications of Artificial Intelligence, 531-537. New York: AAAI Press.

Malik, P. K., Sharma, R., Singh, R., Gehlot, A., Satapathy, S. C., Alnumay, W. S., Pelusi, D., Ghosh, U., & Nayak, J. (2021). "Industrial Internet of Things and Its Applications in Industry 4.0: State of the Art." Computer Communications 166 (2021): 125-139. DOI: 10.1016/j.comcom.2020.11.016.

<a name="te"> Ricker, N. L. (2002). Tennessee Eastman Challenge Archive, MATLAB 7.x Code. Retrieved from University of Washington, Seattle, Department of Chemical Engineering: http://depts.washington.edu/control/LARRY/TE/download.html.

## <a name="ref"> </a> References for Time-Frequency Analysis  Methods and Applications in SAS® 

Champion, J. 2024. Alesis-Sanctuary-QCard-AcoustcBas-C2. Free Wave Samples. Available https://freewavesamples.com. Accessed June 27, 2024.

Champion, J. 2024. 1980s-Casio-Flute-C5. Free Wave Samples. Available https://freewavesamples.com. Accessed June 27, 2024.

Liao, Y. 2020. “Noninvasive Beehive Monitoring through Acoustic Data Using SAS Event Stream Processing and SAS Viya.” Proceedings of the SAS Global Forum 2020 Conference. Cary, NC: SAS Institute Inc. https://support.sas.com/resources/papers/proceedings20/4509-2020.pdf.

Grenander, U. 1959. “Probability and Statistics: The Harald Cramér Volume.” 

Nikolas. 2024. EEG Dataset. Kaggle. Available https://www.kaggle.com/datasets/samnikolas/eeg-dataset. Accessed June 27, 2024.

Nuttall, A. 1981. “Some Windows with Very Good Sidelobe Behavior.” IEEE Transactions on Acoustics, Speech, and Signal Processing 29:84–91.

SAS Institute Inc. (2024). SAS IML: Language Reference. Retrieved from https://pubshelpcenter.unx.sas.com/test/doc/en/pgmsascdc/v_052/casimllang/titlepage.htm. 


## <a name="ref"> </a> References for Nominal Variables Dimension Reduction Using SAS

Abdi, H., and Valentin, D. (2007). “Multiple Correspondence Analysis.” In Salkind, N. J., ed., Encyclopedia of Measurement and Statistics, 1–13. Thousand Oaks, CA: Sage Publications. Available at https://personal.utdallas.edu/~herve/Abdi-MCA2007-pretty.pdf.

De Leeuw, J. (2006). “Principal Component Analysis of Binary Data by Iterated Singular Value Decomposition.” Computational Statistics and Data Analysis 50:21–39. Available at https://www.sciencedirect.com/science/article/pii/S0167947304002300.

Greenacre, M. (2017). Correspondence Analysis in Practice. 3rd ed. Boca Raton, FL: Chapman and Hall/CRC. 

Khangar, N. V., and Kamalja, K. K. (2017). “Multiple Correspondence Analysis and Its Applications.” Electronic Journal of Applied Statistical Analysis 10(2), 432–462. Available at https://www.academia.edu/125560871/Multiple_Correspondence_Analysis_and_its_applications.

Landgraf, A. J., and Lee, Y. (2020). “Dimensionality Reduction for Binary Data through the Projection of Natural Parameters.” Journal of Multivariate Analysis 180:104668. Available at https://www.sciencedirect.com/science/article/pii/S0047259X20302499.

Michalski, R. S., and Chilausky, R. L. UCI Machine Learning Repository (1980). “Soybean (Large).” UCI MLR. Available at https://doi.org/10.24432/C5JG6Z.


Schein, A. I., Saul, L. K., and Ungar, L. H. (2003). “A Generalized Linear Model for Principal Component Analysis of Binary Data.” In Proceedings of the Ninth International Workshop on Artificial Intelligence and Statistics, 240–247. PMLR. Available at http://proceedings.mlr.press/r4/schein03a/schein03a.pdf.

UCI Machine Learning Repository (1991). “Molecular Biology (Splice-Junction Gene Sequences).” UCI MLR. Available at https://doi.org/10.24432/C5M888. 

UCI Machine Learning Repository (1981). “Mushroom.” UCI MLR. Available at https://doi.org/10.24432/C5959T.

