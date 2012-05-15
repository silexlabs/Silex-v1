function drawShape(
				shape,
				canvas,
				rectWidth,
				rectHeight,
				cornerRadius,
				fillType, fillColor,
				fillAlpha,
				fillColors,
				fillAlphas,
				fillRatios,
				gradientRotation,
				lineThickness,
				jointStyle,
				capStyle,
				lineColor,
				lineAlpha,
				border,
				shadow,
				shadowOffsetX,
				shadowOffsetY,
				shadowBlur,
				shadowColor,
				shadowAlpha,
				bitmapUrl,
				repeatBitmap) {
	
	var targetCanvas = document.getElementById(canvas);
	var yInitialOffset=0;
	var xInitialOffset=0;
	if (shadow)
	{
		targetCanvas.height += Math.abs(shadowOffsetY+ shadowBlur);
		targetCanvas.width += Math.abs(shadowOffsetX + shadowBlur);
		
			targetCanvas.height += lineThickness/2;
			targetCanvas.width += lineThickness/2;
		
		
		if (shadowOffsetX <0)
		{
			targetCanvas.style.position = "absolute";
			targetCanvas.style.left = targetCanvas.style.left + shadowOffsetX +"px";
			xInitialOffset += Math.abs(shadowOffsetX);
		}
		if (shadowOffsetY <0)
		{
			targetCanvas.style.position = "absolute";
			targetCanvas.style.top = targetCanvas.style.top + shadowOffsetY +"px";
			yInitialOffset += Math.abs(shadowOffsetY);
		}
	}
	
	
	
	var mc = targetCanvas.getContext("2d");
	
	
	

	
	switch (fillType)
	{
		case "solid":
		fillColor = cutHex(fillColor);
		mc.fillStyle = "rgba("+hexToR(fillColor)+","+hexToG(fillColor)+","+hexToB(fillColor)+","+(fillAlpha/100).toFixed(2)+")";
				doDrawShape(mc, shape, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset, yInitialOffset,
			shadow, shadowOffsetX, shadowOffsetY, shadowColor, jointStyle, capStyle, lineColor, shadowBlur, lineAlpha, shadowAlpha);
		break;
		
		case "linear":
		
		var gradientRadRotation = gradientRotation/180*Math.PI;
		var xStart =0;
		var yStart =0;
		var xEnd = rectWidth;
		var yEnd = rectHeight;
		
		
		if ((gradientRadRotation > 0) &&( gradientRadRotation <(Math.PI/2)))
		{
			xStart = 0;
			yStart = 0;
			xEnd = rectHeight/ Math.tan(gradientRadRotation) ;
			yEnd = rectHeight;
		}
		
		else if (gradientRadRotation >= (Math.PI/2) && gradientRadRotation < Math.PI)
		{
			xStart = rectWidth;
			yStart = 0;
			xEnd = rectWidth - (rectHeight / Math.tan(Math.PI - gradientRadRotation)) ;
			yEnd = rectHeight;
		}
		
		else if (gradientRadRotation >= Math.PI && gradientRadRotation < Math.PI * (3/2))
		{
			xStart = rectWidth;
			yStart = rectHeight;
			xEnd = rectWidth -(rectHeight /Math.tan((Math.PI*(3/2))-gradientRadRotation));
			yEnd = 0;
		}
		
		else if (gradientRadRotation >= Math.PI * (3/2) && gradientRadRotation < Math.PI * 2)
		{
			xStart = 0;
			yStart = rectHeight;
			xEnd = rectHeight / Math.tan((Math.PI*2)-gradientRadRotation) ;
			yEnd = 0;
		}
		
		
		var gradient = mc.createLinearGradient(xStart,yStart,xEnd,yEnd);
		
		for (var i = 0; i<fillColors.length; i++)
		{
			gradient.addColorStop(fillRatios[i] / 255, "rgba("+hexToR(fillColors[i])+","+hexToG(fillColors[i])+","+hexToB(fillColors[i])+","+(fillAlphas[i]/100).toFixed(2)+")");
		}
		
		mc.fillStyle = gradient;
				doDrawShape(mc, shape, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset, yInitialOffset,
			shadow, shadowOffsetX, shadowOffsetY, shadowColor, jointStyle, capStyle, lineColor, shadowBlur, lineAlpha, shadowAlpha);
		break;
		
		case "radial":
		
		var radius;
		var xscale;
		if (rectHeight > rectWidth)
		{
			radius = rectWidth;
			xscale = rectHeight/rectWidth;
		}
		else
		{
			radius = rectHeight;
			xscale = rectWidth/rectHeight;
		}
		
		var gradient = mc.createRadialGradient(rectWidth / 2,rectHeight / 2,0,rectWidth / 2, rectHeight / 2, radius);
		
		for (var i = 0; i<fillColors.length; i++)
		{
			gradient.addColorStop(fillRatios[i] / 255, fillColors[i]);
		}
		mc.fillStyle = gradient;
				doDrawShape(mc, shape, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset, yInitialOffset,
			shadow, shadowOffsetX, shadowOffsetY, shadowColor, jointStyle, capStyle, lineColor, shadowBlur, lineAlpha, shadowAlpha);
		break;
		
		case "bitmap":
		var img = new Image();
		
		
		img.onload = function (){
			
			var patternRepeat;
			if (repeatBitmap == true)
			{
				patternRepeat = 'repeat';
			}
			else
			{
				patternRepeat = 'no-repeat';
			}
			var pattern = mc.createPattern(img, patternRepeat);
			mc.fillStyle = pattern;
					doDrawShape(mc, shape, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset, yInitialOffset,
			shadow, shadowOffsetX, shadowOffsetY, shadowColor, jointStyle, capStyle, lineColor, shadowBlur, lineAlpha, shadowAlpha);
			
		}
		
		img.src = bitmapUrl;
		break;
	}
	


	
}

function doDrawShape(mc, shape, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset, yInitialOffset,
			shadow, shadowOffsetX, shadowOffsetY, shadowColor, jointStyle, capStyle, lineColor, shadowBlur, lineAlpha, shadowAlpha)
{
		switch (shape)
	{
		case "Rectangle" :
		doDrawRoundedRectangle(mc, cornerRadius, border, lineThickness, rectWidth, rectHeight, xInitialOffset,yInitialOffset);
		break;
		
		case "Ellipse" :
		doDrawEllipse(mc, border, lineThickness, rectWidth, rectHeight);
		break;
	}
	
	
	if (shadow)
	{
		mc.shadowOffsetX = shadowOffsetX ;
		mc.shadowOffsetY = shadowOffsetY;
		mc.shadowBlur = shadowBlur;
		mc.shadowColor = "rgba("+hexToR(shadowColor)+","+hexToG(shadowColor)+","+hexToB(shadowColor)+","+shadowAlpha.toFixed(2)+")";
	}
	
	mc.fill();
	
	if (border)
	{
		//mc.shadowColor = "rgba("+hexToR(shadowColor)+","+hexToG(shadowColor)+","+hexToB(shadowColor)+","+0+")";
		mc.strokeStyle = "rgba("+hexToR(lineColor)+","+hexToG(lineColor)+","+hexToB(lineColor)+","+(lineAlpha/100).toFixed(2)+")";
		mc.lineJoin = jointStyle;
		if (capStyle = "none")
		{
			mc.lineCap = "butt";
		}
		else
		{
			mc.lineCap = capStyle;
		}
		mc.lineWidth = lineThickness;
		mc.stroke();
	}
}

function doDrawRoundedRectangle(mc, cornerRadius, border, lineThickness, width, height, xInitialOffset, yInitialOffset)
{
	var xOffset = xInitialOffset;
	var yOffset = yInitialOffset;
	var widthOffset = - xInitialOffset;
	var heightOffset = - yInitialOffset ;
	
	if (border == true)
	{
		xOffset += lineThickness / 2;
		yOffset += lineThickness / 2;
		widthOffset += (lineThickness / 2)  ;
		heightOffset += (lineThickness / 2) ;
	}
	
	var tlCornerRadius = cornerRadius[0];
	var trCornerRadius = cornerRadius[1];
	var brCornerRadius = cornerRadius[2];
	var blCornerRadius = cornerRadius[3];
	
	mc.beginPath();
	
	mc.moveTo(tlCornerRadius + xOffset, yOffset);
	mc.lineTo(width - trCornerRadius - widthOffset, yOffset);
	
	
	mc.quadraticCurveTo(width - widthOffset, yOffset, width - widthOffset, trCornerRadius + yOffset );
	mc.lineTo(width - widthOffset, trCornerRadius + yOffset);
	mc.lineTo(width - widthOffset, height - brCornerRadius - heightOffset);
	mc.quadraticCurveTo(width - widthOffset, height - heightOffset, width - brCornerRadius - widthOffset, height - heightOffset);
	mc.lineTo(width - brCornerRadius - widthOffset, height - heightOffset);
	mc.lineTo(blCornerRadius + xOffset, height - heightOffset);
	mc.quadraticCurveTo(xOffset, height - heightOffset, xOffset, height - blCornerRadius - heightOffset);
	mc. lineTo(xOffset, height - blCornerRadius - heightOffset);
	mc. lineTo(xOffset, tlCornerRadius + yOffset);
	mc.quadraticCurveTo(xOffset,yOffset, tlCornerRadius + xOffset, yOffset);
	mc. lineTo(tlCornerRadius + xOffset, yOffset);
	
	mc.closePath();
	
}

function doDrawEllipse(mc, border, lineThickness, width, height){
		
		mc.beginPath();
		var xRadius = (width / 2) - (lineThickness / 2);
		var yRadius = (height / 2) - (lineThickness / 2);
		
		var x = (width / 2) ;
		var y = (height / 2) ;
		
		var angleDelta = Math.PI / 4;
		var xCtrlDist = xRadius/Math.cos(angleDelta/2);
		var yCtrlDist = yRadius/Math.cos(angleDelta/2);
		var rx, ry, ax, ay;
		
		mc.moveTo(x + xRadius, y);
		var angle = 0;
		
		for (var i = 0; i < 8; i++) {
		angle += angleDelta;
		rx = x + Math.cos(angle-(angleDelta/2))*(xCtrlDist);
		ry = y + Math.sin(angle-(angleDelta/2))*(yCtrlDist);
		ax = x + Math.cos(angle)*xRadius;
		ay = y + Math.sin(angle)*yRadius;
		mc.quadraticCurveTo(rx, ry, ax, ay);
		}
	
		mc.closePath();
}

function hexToR(h) {return parseInt((cutHex(h)).substring(0,2),16)}
function hexToG(h) {return parseInt((cutHex(h)).substring(2,4),16)}
function hexToB(h) {return parseInt((cutHex(h)).substring(4,6),16)}
function cutHex(h) {return (h.charAt(0)=="#") ? h.substring(1,7):h}