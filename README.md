# RandomSlopesIntcpts
This repository shows you how to run a varying-intercepts and varying-slopes
model on longitudinal neurocognitive assessments.

This is the model to be fitted:
$$
\begin{aligned}
\mathrm{Level 1:} \phantom{2cm} & \\
        y_{i[t]} &\sim \mathrm{N}\bigl(\alert<2>{ \alpha_{i} } + %
        \alert<2>{ \beta_{i} }\mathrm{Months}_{i[t]}, \sigma^2_{\epsilon}\bigr),\ %
    \mathrm{for}\ i = 1, \dots, n;\quad  t = 1, \dots, 4  \\
\mathrm{Level 2:} \phantom{2cm} & \\
    \begin{pmatrix}
    \alpha_{i}\\
    \beta_{i}
    \end{pmatrix} &\sim \mathrm{N} \Biggl(
      \begin{pmatrix}
       \alert<3>{\mu_{\alpha}}\\
       \alert<3>{\mu_{\beta}}
      \end{pmatrix}\! \! , \
      \alert<3>{\Omega}    
      % NOTE: thin negative space to make \lq look nicer
      \Biggr), \\
    \mathrm{where}& \\
        \mu_{\alpha} &= %
        \gamma_{00} + %
        \gamma_{01} \alert<4>{\mathrm{Age}_i} + %
        \gamma_{02} \alert<4>{\mathrm{Age}^2_i} + %
        \gamma_{03} \mathrm{survivor}_i + \\
        & \qquad \qquad 
        \gamma_{04} \mathrm{survivor}_i\cdot \alert<4>{\mathrm{Age}_i} + %
        \gamma_{05} \mathrm{survivor}_i\cdot \alert<4>{\mathrm{Age}^2_i} %
        \\
        \mu_{\beta} &= %
        \gamma_{10} + \gamma_{11} \mathrm{survivor}_i + %
        \gamma_{12} \alert<4>{\mathrm{age4Q}_i} + %
        \gamma_{13} \mathrm{survivor}\cdot \alert<4>{\mathrm{age4Q}_i}
\end{aligned}
$$
