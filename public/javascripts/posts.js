$(document).ready(function() {
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
                imagesElements += "<div class=\"feed_image\" style=\"background-image: url('" + images[image] + "')\"></div>";
            }
            var newPost = $(
                "<div class=\"post hide\" id=\""+ posts[index].smssid +"\">" +
                imagesElements +
                "<div class=\"feed_caption\">" +
                "<blockquote>" +
                "<p class=\"feed_text\">" + posts[index].body +
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