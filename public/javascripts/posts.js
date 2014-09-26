$(document).ready(function() {
    $("#posts").magnificPopup({
        delegate: 'a',
        type: 'image',
        closeOnContentClick: true,
        closeOnBgClick: true,
        zoom: {
            enabled: true,
            duration: 300,
            opener: function(openerElement) {
                return openerElement.find('div');
            }
        }
    });
    makeAjaxCallForNewPosts();
    poll();
});

function poll() {
    setTimeout(function() {
        makeAjaxCallForNewPosts();
    }, 10000);
}

function makeAjaxCallForNewPosts() {
    $.ajax({
        url: "/posts.json",
        type: "POST",
        success: function(data) {
            addNewPosts(data);
        },
        dataType: "json",
        complete: poll(),
        timeout: 3000
    });
}

function addNewPosts(posts) {
    var postsElement = $("#posts");
    for (index in posts) {
        if (!postsElement.find("#"+posts[index].smssid).length) {
            var images = posts[index].url;
            var imagesElements = "";
            for (image in images) {
                imagesElements += "<a href=\"" + images[image] + "\" title=\"" + posts[index].mention + ": " + posts[index].body + "\"><div class=\"feed_image\" style=\"background-image: url('" + images[image] + "')\"></div></a>";
            }
            if (images == null) {
                var logo = "/images/color_oncolor.png";
                imagesElements += "<div class=\"feed_image\" style=\"background-image: url('" + logo + "')\"></div>";
            }
            var newPost = $(
                "<div class=\"post hide\" id=\""+ posts[index].smssid +"\">" +
                imagesElements +
                "<div class=\"feed_caption\">" +
                "<blockquote>" +
                "<p><span class=\"feed_mention\">" + posts[index].mention + ": </span><span class=\"feed_text\">" + posts[index].body + "</span>" +
                "<br/>" +
                "<span class=\"feed_timestamp\">" + posts[index].smsdatetime + "</span>" +
                "</p>" +
                "</blockquote>" +
                "</div>" +
                "</div>");
            postsElement.prepend(newPost);
            newPost.toggle("hide").animate({width: "99%"},500);
        }
    }
}