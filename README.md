<!DOCTYPE html>
<!-- KaTeX requires the use of the HTML5 doctype. Without it, KaTeX may not render properly -->
<html>
<meta charset="UTF-8">
<head>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.css" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">

<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.js" integrity="sha384-y23I5Q6l+B6vatafAwxRu/0oK/79VlbSz7Q9aiSZUvyWYIYsd+qj+o24G5ZU2zJz" crossorigin="anonymous"></script>

<!-- 
https://stackoverflow.com/questions/27375252/
      how-can-i-render-all-inline-formulas-in-with-katex

$ is not one of the default delimiters so you'll need to set 
it when you call renderMathInElement() and set display to false, 
which renders inline.
-->
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous" 
onload="renderMathInElement(document.body,
    {
    delimiters: [
        {left: '$$',   right: '$$',  display: true},
        {left: '\\[',  right: '\\]', display: true},
        {left: '$',    right: '$',   display: false},
        {left: '\\(',  right: '\\)', display: false}
    ]
    }
    );"
></script>
<style>
  .katex-version {display: none;}
  .katex-version::after {content:"0.10.2 or earlier";}
</style>
<span class="katex">
  <span class="katex-mathml">The KaTeX stylesheet is not loaded!</span>
  <span class="katex-version rule">KaTeX stylesheet version: </span>
</span>
</head>

<body>
<div>
<p>


# RandomSlopesIntcpts
This repository shows you how to run a varying-intercepts and varying-slopes
model on longitudinal neurocognitive assessments.
Inverse Gamma distribution $IG(\alpha, \beta)$.
</p>
<p>
The <u>inverse Gamma</u> 
distribution, according to Wikipedia, 
has the following density function:
\[
f(x; \alpha, \beta) = \frac{\beta^\alpha}{\Gamma(\alpha)}%
(1/x)^{\alpha + 1}\exp(-\beta / x),\tag{1}
\]
where $\alpha$ is the <u>shape</u> parameter and $\beta$ is the 
<u>scale</u> parameter.  
The inverse Gamma is the conjugate distribution
for the variance of a normal distribution.
</p>
<p>
Note that, on Wikepedia, the <u>Gamma</u> 
distribution has two 
parameterizations.  One is by the 
<u>shape</u> and
<u>scale</u> 
parameterization, the other is the 
<u>shape</u> and
<u>rate</u> 
parameterization (where scale = 1/rate).
However, as shown in the equation above, Wikipedia
on the
<u>inverse Gamma</u> 
distribution has only one parameterization by
the 
<u>shape</u> and
<u>scale</u> 
parameters.

This caused some confusing for me.
For example, Carlin &amp; 
Louis (1996) specify the prior for 
$\sigma^2 \sim IG(a, b)$ (Eq. (5-18) on p. 166).
It was unclear whether $b$ was the scale or rate parameter.
Later equations suggested
the shape-rate parameterization.
However, on p.169, the equation for the posterior uses 
the inverse of the rate parameter (notice the inverse signs).
</p>
<p>
Thus, to minimize confusion, 
it is probably much easier to consistently use
the shape-scale parameterization throughout the derivations,
shown below.  Also, the shape-scale
parameterization is the default in the rinvgamma()
function in MCMCpack, which I use to draw the samples.
</p>
</div>
<div>
<p>
The conditional posterior distribution for $\sigma^2$ is 
proportional to the product
of the data likelihood and the prior:
\[
\begin{aligned}
p(\sigma^2 | y_i, \theta_1, \theta_0, \Sigma) & \propto %
\Big(\Pi_{i=1}^{k} p(y_i|X_i\theta_i, \sigma^2)\Big) p(\sigma^2 | a, b) \\
& \propto \frac{1}{[\sigma^2]^{N/2}}%
\exp\Big(- \frac{1}{2\sigma^2} \sum_{i=1}^{k} %
(y_i - X_i\theta_i)^T (y_i - X_i\theta_i)\Big) %
\frac{1}{[\sigma^2]^{a+1}} \exp(-b/\sigma^2) \\
& = \frac{1}{[\sigma^2]^{(N/2)+a+1}} %
\exp\Big(-\frac{1}{\sigma^2}\Big[\frac{1}{2}%
\sum_{i=1}^k (y_i - X_i\theta_i)^T(y_i-X_i\theta_i) + b\Big]\Big)
\end{aligned}
\]
The data likelihood,
$\Pi_{i=1}^{k} p(y_i|X_i\theta_i, \sigma^2)$,
is the density of $y_i$ with respect to a normal distribution
with known mean $X_i\theta_i$ and unknown variance $\sigma^2$,
multiplied across $i=1,2,\dots,k$ clusters 
(details see Gelman et al., section 2.6). The prior,
$p(\sigma^2 | a, b)$, is the inverse gamma density.
Then from the second to the third line, we collect and 
rearrange the terms, e.g., 
$\frac{1}{[\sigma^2]^{N/2}} \times \frac{1}{[\sigma^2]^{a+1}}%
 = \frac{1}{[\sigma^2]^{(N/2)+a+1}}$.
</p>
<p>
If you look at the equation of the density of the inverse Gamma 
distribution above, this implies that 
$\sigma^2$ has a conditional posterior density of
\[
p(\sigma^2 | y_i, \theta_1, \theta_0, \Sigma) \sim %
IG\Big(N/2+a, \Big[\frac{1}{2} %
\sum_{i=1}^k (y_i - X_i\theta_i)^T(y_i-X_i\theta_i) + b\Big]\Big),
\]
where $N/2+a$ is the posterior 
<u>shape</u>
and 
$\Big[\frac{1}{2} \sum_{i=1}^k (y_i - X_i\theta_i)^T(y_i-X_i\theta_i) + b\Big]$
is the posterior 
<u>scale</u>
parameter; and that 
$N = 5(30) = 150$.
</p>
<p>
The posterior scale parameter may appear intimidating,
$\Big[\frac{1}{2} \sum_{i=1}^k (y_i - X_i\theta_i)^T(y_i-X_i\theta_i) + b\Big]$,
but it is simply the sum of squares of the deviations $(y_i - X_i\theta_i)$.
Sums of squares are used frequently in 
statistical formulas, i.e., squaring all of the elements in a 
vector and then taking the sum of those squares.
The sum of squares for all 
the elements of a vector is calculated according to the 
following matrix algebra formula:
\[
\sum x_i^2 = x^T x,
\]
where $x^T x$ is sometimes written as $x' x$ instead,
and 
$x$ is an $n\times 1$ column vector of scores: $x_1, x_2, \dots, x_n$,
and $\sum x_i^2$ is the sum of the squared values from vector $x$.
</p>
<p>
To illustrate, we try it on a column vector $x$, where its
row vector $x^T = [1, 2, 3]$.
\[
\begin{aligned}
\sum x_i^2 & = \left[
\begin{array}{ccc}
1 & 2 & 3
\end{array}
\right]
\left[
\begin{array}{c}
1\\
2\\
3
\end{array}
\right]  \\
& = \begin{array}{ccc}
\phantom{1} & x^T & \phantom{3}
\end{array} \quad
\begin{array}{c}
x\\
\end{array} \\
& = (1 \times 1) + (2 \times 2) + (3 \times 3)\\
& = 1 + 4 + 9 = 14.
\end{aligned}
\]
</p>
<p>
More generally, $x^T x$ yields the sums of squares and cross products 
matrix (aka SSCP matrix), which gets used frequently in statistics. 
</p>

</div>

</body> 
</html>
