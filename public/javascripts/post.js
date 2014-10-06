$(document).ready(function() {
    getImgSize($("#polaroid_image img"));
    $(".polaroid").delay(300).fadeIn(500);

    var image = $("#polaroid_image img");
    setTimeout(function() {
       image.animate({opacity: '1'});
    }, 20);
});

function getImgSize(img) {
    var newImg = new Image();

    newImg.onload = function() {
        var height = newImg.height;
        var width = newImg.width;
        var newHeight = img.height();
        var newWidth = Math.ceil(width * (newHeight / height));

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