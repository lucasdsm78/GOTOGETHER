# to erase file and open it to insert new data
if [ -z "$1" ];
then
  echo "give a file to update after 'sh up.sh', here an example : 'sh up.sh main.py'";
else
  rm $1;
  vi $1;
fi
