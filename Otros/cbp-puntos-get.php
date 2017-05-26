<?php
/**
 * Created by PhpStorm.
 * User: leopinzon
 * Date: 8/1/15
 * Time: 9:22 PM
 */

try{
   if(!is_numeric($_GET['cc'])){
        echo "Error - C&eacute;dula no num&eacute;rica ";
    }else{

echo "Paso 1";
$service_url = 'http://190.85.214.13:8080/fidelizacion/yanuba/service/datos/38988551';
/*$service_url = 'http://www.google.com';*/
$curl = curl_init($service_url);
echo "Paso 2";
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
echo "Paso 3";
$curl_response = curl_exec($curl);
echo "Paso 4";
echo $curl_response;
echo "Paso 5";
curl_close($curl);
echo "Paso 6";
/*
http://190.85.214.13:8080/fidelizacion/yanuba/service/datos/79156615

if ($curl_response === false) {
    $info = curl_getinfo($curl);
    curl_close($curl);
    die('error occured during curl exec. Additioanl info: ' . var_export($info));
}





    $ctx = stream_context_create(array(
            'http' => array(
                'timeout' => 10
            )
        )
    );
    ini_set("allow_url_fopen", true);
    $response_puntos = file_get_contents("http://190.85.214.13:8080/fidelizacion/yanuba/service/datos/". $_GET['cc'],false,$ctx);
	
	echo $response_puntos;*/
    }
}catch(Exception $e){
    echo $e->getMessage();
}
