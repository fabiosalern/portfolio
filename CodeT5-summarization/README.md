# Fine-Tuninig CodeT5 on Ruby Summarization
Source code summarisation, aims to generate concise and coherent human-readable summaries for code comprehension. CodeT5, a Transformer-based model fine-tuned for code summarisation, is evaluated on Ruby source code using three variations: CodeT5-base-multi-sum (multilingual), CodeT5-small (fine-tuned on Ruby), and CodeT5-base-multi-sum (fine-tuned on Ruby). This project aims to investigate the effectiveness of these models in summarising Ruby code and explores the potential of leveraging information from other languages to enhance summarisation.

The ropository is composed by two folders:
- `Notebooks`
- `Functions`

The `Notebooks` folder contains three notebooks:
- The notebooks with the code step by step for fine-tuning each model:
  - `FineTuning_CodeT5_multi_sum.ipynb`
  - `FineTuning_CodeT5_small.ipynb`
- `Inference.ipynb`,  with the code step by step for performing the inference and the evaluation for each model on the tes tset

The `Functions` folder contains all the functions designed for accomplishing this project, in this way they are easy to be retrieved instead of digging into the notebooks; the folder contains:
- `eval_metrics.py` whith all the functions used for the evaluation of the summaries
-  `inference.py` with the function used to perform the inference in batches.
-  `pythorch_lightning_modules.py` the two pythorch_lightning_modules used for performing the two fine-tuninings.

Finally there's: `Fine_tuning_codeT5_Ruby_summarisation.pdf` which is a small report where the project, the methodologies and the results are described.
