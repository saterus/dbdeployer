function deploy_file() {
  _deploy_file="$1"
  _logfile="$2"


  deploy_output=$(${db_binary} -d ${dbname} ${server_flag}${port_flag} ${user_flag} ${password_flag} -h -1 -e -b -i "${fn_basedir}"/dbtype/"${dbtype}"/pre_deploy.sql "$_deploy_file" "${fn_basedir}"/dbtype/"$dbtype"/post_deploy.sql)
  rc=$?

  echo "${deploy_output}"

  echo "${deploy_output}" >> "${_logfile}" 




  if [[ $deploy_output == *"SqlState 24000, Invalid cursor state"* ]]
  then
    echo
    echo "File failed to deploy within a transaction.  This is most likely due to a bug in the Linux SQLCMD utility.  Would you like to try deploying outside a transaction?";
    
    select yn in "Yes" "No"; do
        case ${yn} in
            Yes ) 
              deploy_output=$(${db_binary} -d ${dbname} ${server_flag}${port_flag} ${user_flag} ${password_flag} -h -1 -e -b -i "$_deploy_file")
              rc=$?

                echo "${deploy_output}"

                echo "${deploy_output}" >> "${_logfile}" 

                  if [[ $deploy_output == *"SqlState 24000, Invalid cursor state"* ]]
                  then
                    echo
                    echo "File failed to deploy outside a transaction.  You'll need to deploy manually and skip";
                    rc=1    
                  fi
                  
              break;;
            No )
              rc=1 
              exit;;
        esac
      done

  fi


  unset _deploy_file
  unset _logfile

  if [ ${rc} -eq 0 ]
  then
    return 0
  else
    return 1
  fi
}



function deploy_file_check_ms_bug {

  if [[ $deploy_output == *"SqlState 24000, Invalid cursor state"* ]]
  then
    return 1
  else
    return 0
  fi

}



function deploy_file_no_tran() {


  if [[ $deploy_output == *"SqlState 24000, Invalid cursor state"* ]]
  then
    echo
    echo "File failed to deploy within a transaction.  This is most likely due to a bug in the Linux SQLCMD utility.  Would you like to try deploying outside a transaction?";
    
    select yn in "Yes" "No"; do
        case ${yn} in
            Yes ) 
              deploy_output=$(${db_binary} -d ${dbname} ${server_flag}${port_flag} ${user_flag} ${password_flag} -h -1 -e -b -i "$_deploy_file")
              
                echo "${deploy_output}"

                echo "${deploy_output}" >> "${_logfile}" 

              break;;
            No )
              rc=1 
              exit;;
        esac
      done

  fi

}
