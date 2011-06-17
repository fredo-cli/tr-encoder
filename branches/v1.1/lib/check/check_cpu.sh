

  ### check the number of CPU

  NB_CPU=$(grep processor /proc/cpuinfo|wc -l)
  echo -e "$GREEN CPU: $NB_CPU $NC"

  ### check th efrquence of the CPU

  FREQ_CPU=$(grep "cpu MHz" /proc/cpuinfo| awk '{print $4/1}'|head -1)
  echo -e "$GREEN FREQ: $FREQ_CPU $NC"

  ### get the total

  FREQ_TOTAL=$(echo "$FREQ_CPU * $NB_CPU" |bc)
  echo -e "$GREEN FREQ TOTAL: $FREQ_TOTAL $NC"
