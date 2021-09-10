# Ensemble plots

This workflow watches for met office plots appearing checking every 5 mins for a new folder and then waits for all the plots to appear before harvesting the requested plots and putting them into reduced size powerpoint presentations available via [jasmin public html](http://gws-access.jasmin.ac.uk/public/swift/TestBed3/).

## To run automation

` ./dry_run.sh > logs 2> err &`

## PowerPoint contents

One ppt for each country:
  1. CP 0300Z, global 0000Z
  2. CP 1500Z, global 1200Z

  * 24hr accumulations on West Africa cutout in Senegal, Ghana, Nigeria and East Africa cutout in Kenya
  * 3hr accumulations on individual country cutout

*Convection-permitting*
  * T+24-48, 48-72 (24hr accum) Neighbourhood probability of rainfall exceeding 32, 64, 128 mm h-1
  * T+24-48,48-72 (24hr accum) postage stamps
  * T+24-27,27-30,30-33,33-36,36-39,39-42,42-45,45-48,48-51,51-54,54-57,57-60,60-63,63-66,66-69,69-72 (3hr accum) Neighbourhood probability of rainfall exceeding 16 mm h-1
  * T+24-27,27-30,30-33,33-36,36-39,39-42,42-45,45-48,48-51,51-54,54-57,57-60,60-63,63-66,66-69,69-72  (3hr accum) postage stamps


*Global*
  * T+27-30,30-33,33-36,36-39,39-42,42-45,45-48,48-51,51-54,54-57,57-60,60-63,63-66,66-69,69-72,72-75 (3hr accum) Neighbourhood probability of rainfall exceeding 16 mm h-1
  * T+27-30,30-33,33-36,36-39,39-42,42-45,45-48,48-51,51-54,54-57,57-60,60-63,63-66,66-69,69-72,72-75  (3hr accum) postage stamps

Note, global valid times should match CP valid times

Meteograms (Global and CP)

More cities have been requested for Kenya and Ghana, waiting for go-ahead from James@MO

*Senegal*
* Dakar
* Tambacounda
* Touba
*Ghana*
* Accra
* Kumasi
* Tamale
*Nigeria*
* Abuja
* Kano
* Lagos
*Kenya*
* Lake Victoria
* Mombasa
* Nairobi
