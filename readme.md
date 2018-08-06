Pitch Report is a nyquist-style analyze plug-in for Audacity written in the nyquist variation of xlisp.

Pitch Report is used to generate a table of data measuring the fundamental pitch of guitar strings.

These data are collected in an apparatus that generates a constant tension force and allows measurement
of pitch at 650 mm and 325 mm scale lengths.

When measuring the pitch at 325 mm the distance the string is depressed by fretting is also measured.

These data along with additional measurements of physical properties of the strings are used to calculate
the longitudinal stiffness of each string which is then later used to calculate nut and saddle conpensation.

Pitch Report is copyright by Stephen Bannasch 2018 and is Released under GPL v2.

Pitch Report is derived from code in the Audacity Pitch Detect plugin written and copyrighted by Steve Daulton (www.easyspacepro.com) and released under GPL v2.

### Setup

To setup for use with Audacity on macos:

1. Clone repository.
2. Make a symbolic link in `~/Library/Application Support/audacity/Plug-Ins` to `pitch-report.ny` file
in cloned repository.
```
$ cd ~/Library/Application\ Support/audacity/Plug-Ins
$ ln -s ~/path/to/repository/pitch-report.ny pitch-report.ny
```
3. Open Audacity and select menu item: "Analyze:Add / Remove Plug-ins..." and enable plugin Pitch Report.

### Useage

Using Pitch Report plugin.

1. Record sample in track and select menu plugin: "Analyze:Pitch Report".
2. Click the "Debug" button.

A tab-delimited report similar to the following is generated. Multiple tracks can be selected to generate
one report with data from multiple tracks.

```
project           Daddario-EJ15-extra-light-650mm-9070g
date              2018-07-31
time              17:34:49
sample-time       0.250
sample-step-time  0.063
sample-stop-time  2.000
tracks            1

track             E4-650
number            1
average freq      364.445
variance          4.459
stdev             2.112
time              frequency         confidence        RMS
0.000             362.561           0.990             0.070
0.063             366.653           0.985             0.105
0.126             364.623           0.997             0.139
0.189             364.807           0.997             0.139
0.252             364.469           0.996             0.133
0.315             363.261           0.991             0.128
0.378             363.685           0.994             0.121
0.441             363.864           0.994             0.112
0.504             363.266           0.988             0.105
0.567             363.508           0.990             0.099
0.630             364.622           0.990             0.093
0.693             365.628           0.995             0.086
0.756             365.967           0.993             0.079
0.820             363.970           0.991             0.072
0.883             363.442           0.987             0.065
0.946             363.078           0.989             0.060
1.009             360.998           0.983             0.055
1.072             365.551           0.979             0.051
1.135             365.935           0.982             0.048
1.198             362.841           0.972             0.045
1.261             361.289           0.981             0.042
1.324             363.886           0.983             0.040
1.387             363.772           0.986             0.038
1.450             365.864           0.984             0.037
1.513             367.622           0.982             0.035
1.576             369.829           0.962             0.034
1.639             363.178           0.967             0.033
1.702             360.641           0.969             0.032
1.765             364.820           0.982             0.031
1.828             369.646           0.968             0.031
1.891             366.680           0.970             0.030
1.954             362.281           0.980             0.029
```

### References

Audacity and Nyquist

- [Audacity and Nyquist](http://www.audacity-forum.de/download/edgar/nyquist/nyquist-doc/nyquist.htm)
- [Nyquist Reference Manual](http://www.audacity-forum.de/download/edgar/nyquist/nyquist-doc/manual/home.html)
- [Nyquist Examples and Tutorials](http://www.audacity-forum.de/download/edgar/nyquist/nyquist-doc/examples/examples.htm)

Nyquist Plug-ins in Audacity

- [Audacity Nyquist Analyze Plug-ins](https://wiki.audacityteam.org/wiki/Nyquist_Analyze_Plug-ins)
- [Audacity Nyquist Plug-in Programming and Development Forum](https://forum.audacityteam.org/viewforum.php?f=39)
- [Audacity Nyquist Plug-ins Reference](https://wiki.audacityteam.org/wiki/Nyquist_Plug-ins_Reference)

CMU Nyquist xlisp language for sound synthesis and music composition

- [CMU Nyquist Music Programming home page](https://www.cs.cmu.edu/~music/music.software.html)
- [CMU Nyquist html documentation](http://www.cs.cmu.edu/~rbd/doc/nyquist/index.html)

YIN

- [YIN, a fundamental frequency estimator for speech and music](http://audition.ens.fr/adc/pdf/2002_JASA_YIN.pdf)
- [YIN Pitch detection Algortithm (how do I improve results)](https://dsp.stackexchange.com/questions/17493/yin-pitch-detection-algortithm-how-do-i-improve-my-results)
