jQuery(function() {
  if ($('#infinite-scrolling').size() > 0) {
    return $(window).on('scroll', function() {
      var more_pictures_url;
      more_pictures_url = $('.next_page').attr('href');
      if (more_pictures_url && $(window).scrollTop() > $(document).height() - $(window).height() - 80) {
        $('.pagination').html('<center align="center"><img src="/assets/gif-loader-image.gif" alt="Loading..." title="Loading..." /></center>');
        $.getScript(more_pictures_url);
      }
      return;
    });
  }
});
