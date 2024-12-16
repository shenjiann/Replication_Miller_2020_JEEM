# Replication for Panel Causal Forest

This is the replication of [*Miller, S. (2020). Causal forest estimation of heterogeneous and time-varying environmental policy effects. Journal of Environmental Economics and Management, 103, 102337.*](https://www.sciencedirect.com/science/article/pii/S0095069620300607)
### Data Generating Process
$x_1, x_2 \sim uniform[0,1]$ i.i.d

**DGP1:** unconfounded case

$$ y_{it} = T_{it} \tau(x_1, x_2, D_{it}, S_{it}) $$

$$ P(T_{it} = 1 | T_{it-1}=0, x_1, x_2, t) = 0.025 $$

$$ \tau(x_1, x_2, D_{it}, S_{it}) = 5 \cdot 1\{x_2 \leq 0.5\} + d - 0.025 d^2 + 0.001 d \cdot 1\{x_2 \leq 0.5\} + 0.2 (s-1980) $$

**DGP2:** confounded but uncorrelated error

$$ P(T_{it} = 1 | T_{it-1}=0, x_1, x_2, t) = 0.02 + 0.01 x_2 $$

**DGP3:** confounded and correlated error

$$ cov(\varepsilon_{it}, \varepsilon_{is}) = 0.3 \cdot 1 \{|s-t| = 1\} + 0.1 \cdot 1\{|s-t|=2\} $$

### Estimation Algorithm

1. Data Pre-processing: 
Replicate control observations for any values of $s$ and $d$. For example, an untreated observation in 2017 could act as a control for $d = 1$ and $s = 2017$, or as a control for $d = 2$ and $s = 2016$.
To save on computation, each untreated observation could be replicated for a random subset of the (d, s) pairs for which it could serve as a potential control.

2. Tree Procedures:
Use a panel subsampling approach in which all observations from a given panel unit are either included or excluded from the sample used to construct each tree.