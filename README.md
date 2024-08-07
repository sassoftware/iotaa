# IOTAA Repo for Technical Papers


## Overview

 The purpose is to facilitate sharing code and data needed to customers from published technical papers from the IOTAA team. A link to ALL Technical papers published within SAS can be found at [Technical Papers | SAS Support](https://support.sas.com/en/technical-papers.html)

**Technical Papers linked to this repository:**

- Coming soon: Time-Frequency Analysis  Methods and Applications in SAS®
- Coming soon: Fault Identification Using Dynamic Bayesian Networks

### List of Examples
| File/Folder | Application |
| ------ | ------ |
|Fault Identification Using Dynamic Bayesian Networks/TE.sas| Fault identification using dynamic Bayesian networks for Tennessee Eastman chemical plant process.|
|Fault Identification Using Dynamic Bayesian Networks/two_tank.sas| Fault identification using dynamic Bayesian networks for two-tank data.|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Music Decomposition with EMD and HHT| Instrument-Based Music Decomposition|
Signal Processing Methods and Applications in SAS/Examples and Datasets/Feature Extraction from EEG using EMD| Analyzing EEG Signals|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Queen Bee Piping Example 1|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Queen Bee Piping Example 2|


### List of Datasets required for Examples
| File/Folder | Application |
| ------ | ------ |
|Fault Identification Using Dynamic Bayesian Networks/TE| A folder containing data for TE.sas. Generated using PROC IML code based on code from [Ricker (2002).](#te)|
|Fault Identification Using Dynamic Bayesian Networks/two_tank| A folder containing data for two_tank.sas. Adapted from [Lerner et al. (2000).](#tank)|
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Feature Extraction from EEG using EMD/eeg.sas7bdat| Dataset used for EEG feature extraction.
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Music Decomposition with EMD and HHT| Three audio files used for the music decomposition example. The files are bass.wav, flute.wav, combo.wav| 
|Signal Processing Methods and Applications in SAS/Examples and Datasets/Queen Bee Piping Part I and Part II|Three sas datasets needed to run the Queen bee piping detection examples. The datasets are fs.sas7bdat, spectral_adj.sas7bdat, and spectral_data.sas7bdat|


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
