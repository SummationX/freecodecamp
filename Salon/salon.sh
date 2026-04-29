#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --csv --tuples-only -c"

echo -e "\nPlease choose a service:\n"

MAIN_MENU()
{
  if [[ -z $1 ]]
  then
    echo $1
  fi

  echo -e "\n$($PSQL "SELECT service_id, name FROM services")" | sed 's/,/) /'
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9+]$ ]]
  then
    MAIN_MENU "Please put a number"
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
   
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "Please put a valid service id"
    else
      echo What is your phone number?
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
     
      if [[ -z $CUSTOMER_ID ]]
      then
        echo What is your name?
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
      fi
      
      echo What time are you available for your appointment?
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo I have put you down for a "$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")" at $SERVICE_TIME, $CUSTOMER_NAME.
    fi
  fi

}

MAIN_MENU