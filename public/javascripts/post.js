$(document).ready(function() {
    getImgSize($("#polaroid_image img"));
    $(".polaroid").fadeIn(3000);
    $("#polaroid_image img").fadeIn(3000);
    jQuery("#caption").fitText();
    jQuery("#feed_text").fitText();
});

function getImgSize(img) {
    var newImg = new Image();

    newImg.onload = function() {
        var height = newImg.height;
        var width = newImg.width;
        var newHeight = img.height();
        var newWidth = Math.ceil(width * (newHeight / height));
        console.log('The actual image size is ' + newWidth + '*' + newHeight);

        var polaroidBackground = $("#polaroid_background");
        polaroidBackground.css("height", newHeight+"px");
        polaroidBackground.css("width", newWidth+"px");
        polaroidBackground.css("background", "#000");

        var polaroidImage = $("#polaroid_image");
        polaroidImage.css("height", newHeight+"px");
        polaroidImage.css("width", newWidth+"px");
        polaroidImage.css("background", "#000");

        var polaroid = $(".polaroid");
        polaroid.css("width", (parseInt(newWidth)+80)+"px");
        var caption = $("#caption");
        caption.css("width", (parseInt(newWidth)+40)+"px");
    };

    newImg.src = img.attr("src");
}