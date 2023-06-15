# Handelgroup Bayesian Censoring Project

We will keep our notes and code on dealing with censored variables in Bayesian
models in this repo. My initial idea for this is that we can basically treat
each worked out example or section that we write up as a chapter in this
quarto book, and then when we are ready to pull everything together into the
manuscript that should make it easier, and we could potentially make this
website available with some edits.

## TODO

Here is my initial draft of a TODO list.

- [ ] Basic description of censored data problems
- [ ] Potentially a (brief?) description of how censored data is dealt with
in the frequentist paradigm and why this can be difficult
- [ ] Description of how Bayesian models can handle censoring and a brief
conceptual introduction to our examples, maybe a brief description of the
two different methods. This could be expanded if we learn enough to compare
them.
- [ ] A few worked examples using Stan and potentially `brms` to show how these
models are set up and executed. Ideally I think these would start with a
question and a dataset that motivate the use of a Bayesian model with censored
data. E.g. some examples similar to our CIVIC and norovirus examples.

## Guide to collaborative work

- At some point we probably need to use GH actions to automate building, because
that is the main step of the process where conflicts occur.
- For now, we should try to work in separate documents to prevent conflicts.
- **Try to remember not to commit changes to the docs folder!** We should only
rebuild the site when we know all work has committed and everyone who is working
on the project is ready to do that. Otherwise we will get annoying merge
conflicts that are very annoying to fix.

