<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
////////////////////////////////////////////////////////////////////////
// Authors: Thomas Fétiveau (thomas.fetiveau.tech@gmail.com) alias Zabojad and Alexandre Hoyau alias lexa
////////////////////////////////////////////////////////////////////////
	
	require_once("cgi/includes/file_system_tools.php");
	
	class media_tools{
		var $logger = null;
	
		function media_tools(){
			$this->logger = new logger("media_tools");
		}
		
		/**
		* function outputResizedImage()
		* This script allows to resize a image in different scale modes : showAll, noBorder or noScale.
		* inputs (GET) :
		* . file : the path to the image from Silex root dir (required)
		* . scale : scale mode, showall or noborder or noscale (if not specified, showall by default)
		* . infos_img[0] : width of the image file (use getimagesize in order to retrieve it)
		* . infos_img[1] : height of the image file (use getimagesize in order to retrieve it)
		* . width : the width of the result thumb (cannot be 0 or negative, keep width from source image if not specified)
		* . height : the height of the result thumb (cannot be 0 or negative, keep height from source image if not specified)
		*/
		function outputResizedImage($file, $scale = NULL, $width = NULL, $height = NULL)
		{
			if ($this->logger) $this->logger->debug("outputResizedImage($file, $scale, $width, $height)");
			
			//If GD library is not installed, say sorry
			if(!function_exists("imagecreate")) return "GD library is not installed on this server";
		
			// **
			// access rights 
			
			//instance of file_system_tools
			$cl = new file_system_tools () ;
			
			// make sure we can access the file
			if (!$cl->isAllowed( $file , file_system_tools::READ_ACTION ) )
			{
				if ($this->logger) $this->logger->debug("right access error");
				return "right access error";
			}
			
			// Convert to absolute path
			$file = realpath( ROOTPATH . "/$file" ) ;
			
			// **
			// input and default values
			
			if ( !is_file ( $file ) )
			{
				if ($this->logger) $this->logger->debug('file does not exist');
				return 'file does not exist';
			}
				
			// If no scale mode selected, showAll by default
			if( $scale == NULL ) $scale = 'showall';
				
			// Here are all the information about the original image, if it's actually one.
			$infos_img = getimagesize($file);
			
			if(!$infos_img)
			{
				if ($this->logger) $this->logger->debug('file not an image');
				return 'file not an image' ;
			}
		
			// Require width, else default width = original width
			if ( $width == NULL)
				$width = $infos_img[0] ;
		
			// Require height, else default height = original height
			if ( $height == NULL)
				$height = $infos_img[1] ;
			
			// We do not accept negative of equal to 0 width and height
			if($height <= 0 || $width <= 0)
			{
				return 'width or height cannot be <= 0.0';	
			}

			
			// **
			// scale

			// The Show All option maintains image proportions, crops nothing, and adds padding as needed.
			if( $scale == "showall" )
			{
				$rateW = ( $width > $infos_img[0] ) ? 1 : ( $width / $infos_img[0] ) ;
				
				$rateH = ( $height > $infos_img[1] ) ? 1 : ( $height / $infos_img[1] ) ;
				
				$rate = ( $rateW > $rateH ) ? $rateH : $rateW ;
				
				$src_x = 0 ;
			
				$src_y = 0 ;
			
				$dst_w = (int) ($rate * $infos_img[0] + 0.49) ;
				
				$dst_h = (int) ($rate * $infos_img[1] + 0.49) ;
				
				$src_w = $infos_img[0] ;
				
				$src_h = $infos_img[1] ;
				
				$dst_x = (int) ( $width > $dst_w ) ? ( ( $width - $dst_w ) / 2 ) : 0 ;
			
				$dst_y = (int) ( $height > $dst_h ) ? ( ( $height - $dst_h ) / 2 ) : 0 ;
		
			}
			
			// The No Scale option simply do not scale the image but crops it if destination image is smaller or add padding if larger
			else if( $scale == "noscale" )
			{
				$dst_x = ( $width > $infos_img[0] ) ? ( ( $width - $infos_img[0] ) / 2 ) : 0 ;
			
				$dst_y = ( $height > $infos_img[1] ) ? ( ( $height - $infos_img[1] ) / 2 ) : 0 ;
			
				$src_x = ( $width > $infos_img[0] ) ? 0 : ( ( $infos_img[0] - $width ) / 2 ) ;
			
				$src_y = ( $height > $infos_img[1] ) ? 0 : ( ( $infos_img[1] - $height ) / 2 ) ;
			
				$dst_w = ( $width > $infos_img[0] ) ? $infos_img[0] : $width;
				
				$dst_h = ( $height > $infos_img[1] ) ? $infos_img[1] : $height;
				
				$src_w = $dst_w ;
				
				$src_h = $dst_h ;
				
			}
			
			// The No Border option crops image data but preserves the proportions of the image
			else if( $scale == "noborder" )
			{
				$rateW = $width / $infos_img[0] ;
				
				$rateH = $height / $infos_img[1] ;
				
				$rate = ( $rateW > $rateH ) ? $rateW : $rateH ;
		
				$dst_x = 0 ;
			
				$dst_y = 0 ;
			
				$dst_w = $width;
				
				$dst_h = $height;
				
				$src_w = ( $rateW > $rateH ) ? $infos_img[0] : $infos_img[0] * $rateW / $rateH ;
				
				$src_h = ( $rateW > $rateH ) ? $infos_img[1] * $rateH / $rateW : $infos_img[1] ;
			
				$src_x = ( $rateW > $rateH ) ? 0 : ( $infos_img[0] - $src_w ) / 2 ;
			
				$src_y = ( $rateW > $rateH ) ? ( $infos_img[1] - $src_h ) / 2 : 0 ;
				
			}
			
			header("Content-type: {$infos_img['mime']}");
			
			$imgTemp = imagecreatetruecolor( $width , $height );
		
			if( $infos_img[2] == IMAGETYPE_JPEG )
			{
				$src = imagecreatefromjpeg( $file ) ;
			
				imagecopyresampled( $imgTemp, $src, $dst_x, $dst_y, $src_x, $src_y, $dst_w , $dst_h, $src_w, $src_h ) ;
				
				imagejpeg( $imgTemp) ;
				
			}
			else if( $infos_img[2] == IMAGETYPE_PNG )
			{
				$src = imagecreatefrompng( $file ) ;
				
				imagealphablending( $imgTemp, false ) ;
				
				imagesavealpha( $imgTemp, true ) ;
				
				imagecopyresampled( $imgTemp, $src, $dst_x, $dst_y, $src_x, $src_y, $dst_w , $dst_h, $src_w, $src_h ) ;
		
				imagepng( $imgTemp) ;
			
			}	
			else
			{
				return("unknown image type");
			}
			
			@imagedestroy($imgTemp);
			@imagedestroy($src);
			@imagedestroy($to_image);
		}
	}
?>