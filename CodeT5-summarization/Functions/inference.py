# tokenizer and model must be already defined

def batch_inference(input_dataset, batch_size=20):

  #Extract the methods and the ground_truths(labels)
  methods = [input_dataset["test"]["code"][id] for id, _ in enumerate(input_dataset["test"]["code"])]
  labels = [input_dataset["test"]["docstring"][id] for id, _ in enumerate(input_dataset["test"]["docstring"])]

  #Initializing and defining variables
  max_input_length = 256
  final_output = []

  #Start the batch processing + inference + decoding
  for i in range(0,len(methods), batch_size):

    #Define the batch
    batch = methods[i:i+batch_size]

    #Tokenize the batch
    inputs = tokenizer(batch, max_length=max_input_length, padding="max_length", truncation=True, return_tensors="pt")

    #Inference the batch
    outputs = model.generate(**inputs, max_length=60, min_length=30)

    #Decoding the batch
    summaries = [tokenizer.decode(summary, skip_special_tokens=True) for summary in outputs]
    final_output.append(summaries)

  #merge the sublists
  summy = sum(final_output, [])

  return (summy, labels[0:len(summy)])
