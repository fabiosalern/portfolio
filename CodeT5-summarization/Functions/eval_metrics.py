# ! pip install evaluate

# ! pip install bert_score
# ! pip install rouge_score


# rouge = evaluate.load('rouge')
# bleu = evaluate.load("bleu")
# meteor = evaluate.load('meteor')
# bertscore = load("bertscore")

#nltk basics
# from nltk.corpus import stopwords
# from nltk.tokenize import word_tokenize
# from nltk.corpus import names
# import nltk

# Download the necessary resources
# nltk.download('punkt')
# nltk.download('stopwords')
# nltk.download('names')

# Import the punctuation module
# from string import punctuation

# import pandas as pd
# import numpy as np


def rouge_summary(df):
  summary_results = df.summary_results.tolist()
  ground_truth = df.ground_truth.tolist()

  #rouge computation (3min circa)
  values = rouge.compute(predictions = summary_results, references = ground_truth, use_aggregator= False, use_stemmer=True)

  metrics = ['rouge1', 'rouge2', 'rougeL', 'rougeLsum']
  for elem in metrics:
    print(f"{elem}  mean:{np.round(np.mean(values[elem]), 2)}  std:{np.round(np.std(values[elem]), 2)} ")


def bleu_summary(df):
  summary_results = df.summary_results.tolist()
  ground_truth = df.ground_truth.tolist()

  values = [bleu.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]], tokenizer=word_tokenize, smooth=True)["bleu"] for id in range(0, df.shape[0])]

  precis_0 = [bleu.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]], tokenizer=word_tokenize, smooth=True)["precisions"][0] for id in range(0, df.shape[0])]
  precis_1 = [bleu.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]], tokenizer=word_tokenize, smooth=True)["precisions"][1] for id in range(0, df.shape[0])]
  precis_2 = [bleu.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]], tokenizer=word_tokenize, smooth=True)["precisions"][2] for id in range(0, df.shape[0])]
  precis_3 = [bleu.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]], tokenizer=word_tokenize, smooth=True)["precisions"][3] for id in range(0, df.shape[0])]

  print(f"  Bleu: mean:{np.round(np.mean(values),4)}, std:{np.round(np.std(values),4)}\nunigram_mean:{np.round(np.mean(precis_0),4)}; unigram_std:{np.round(np.std(precis_0),4)}\nbigram_mean:{np.round(np.mean(precis_1),4)}; bigram_std:{np.round(np.std(precis_1),4)}\ntrigram_mean:{np.round(np.mean(precis_2),4)}; trigram_std:{np.round(np.std(precis_2),4)}\nfourgram_mean:{np.round(np.mean(precis_3),4)}; fourgram_std:{np.round(np.std(precis_3),4)}\n")


def meteor_summary(df):
  summary_results = df.summary_results.tolist()
  ground_truth = df.ground_truth.tolist()

  values = [meteor.compute(predictions=[summary_results[id]], references=[[ground_truth[id]]])["meteor"] for id in range(0, df.shape[0])]

  print(f" Meteor: mean:{np.round(np.mean(values),4)}, std:{np.round(np.std(values),4)}")


def bertscore_summary(df):
  summary_results = df.summary_results.tolist()
  ground_truth = df.ground_truth.tolist()

  values = bertscore.compute(predictions=summary_results, references=ground_truth, lang="en", model_type="distilbert-base-uncased")

  metrics = ['precision', 'recall', 'f1']
  for elem in metrics:
    print(f"{elem}  mean:{np.round(np.mean(values[elem]), 2)}  std:{np.round(np.std(values[elem]), 2)} ")
