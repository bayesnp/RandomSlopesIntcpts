# RandomSlopesIntcpts
This repository shows you how to run a varying-intercepts and varying-slopes
model on longitudinal neurocognitive assessments.

This is the model to be fitted:
$$
\begin{aligned}
\mathrm{Level 1:} & \\ y_{i[t]} &\sim \mathrm{N}\bigl(\alert<2>{ \alpha_{i} } + { \beta_{i} }\mathrm{Months}_{i[t]}, \sigma^2_{\epsilon}\bigr),\ \mathrm{for}\ i = 1, \dots, n;\quad  t = 1, \dots, 4  \\ \mathrm{Level 2:} & \\ \begin{pmatrix} \alpha_{i}\\ \beta_{i} \end{pmatrix} &\sim \mathrm{N} \Biggl( \begin{pmatrix} \alert<3>{\mu_{\alpha}}\\ \alert<3>{\mu_{\beta}} \end{pmatrix}\! \! , \
\end{aligned}
$$
