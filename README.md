# Business Economics Homework

Business Economics (M2S1 2021) at the [Toulouse School of Economics](https://tse-fr.eu/) (TSE)

- [:file_folder: Download the PDF](https://github.com/masonrhayes/business_econ/raw/master/submission/bus_econ_hw.pdf)
- [:computer: View the code](scripts/bus_econ_hw.jl)
- [:notebook: Open the notebook](https://masonrhayes.keybase.pub/projects/bus_econ_hw.jl.html)
- [:bar_chart: See the graphics](graphics/)

## How to Reproduce

This homework was done in [Julia](https://julialang.org) using the interactive notebook [Pluto.jl](https://github.com/fonsp/Pluto.jl).

To learn how to run the notebook yourself, you can watch [:tv: this video](https://www.youtube.com/watch?v=OOjKEgbt8AI) or read [:blue_book: this tutorial](https://computationalthinking.mit.edu/Fall20/installation/), which show how to install Julia and start using Pluto.jl.

The notebook is also just a plain Julia file which can be run in your preferred IDE (I recommend [VSCodium](https://vscodium.com/)).

The PDF document and graphics were generated from Julia Markdown using [Weave.jl](http://weavejl.mpastell.com/stable/). They can be reproduced with the following steps:

- Fork this repository
- Run the following code in the Julia REPL

```julia
using Pkg
Pkg.add("Weave")
using Weave
weave("scripts/bus_econ_hw.jmd")
```
