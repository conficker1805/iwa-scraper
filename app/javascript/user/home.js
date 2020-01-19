window.IwaScraper.application = {
  initIndex(){
    let params = new URLSearchParams(window.location.search)
    $.get( '/posts.js', {
      page: params.get('page') || 1
    }, () => {
      let ids = $.map($('.no-image'), (i) => { return $(i).data('id') })

      if (ids.length > 0){
        let source = new EventSource('/images?post_ids=' + ids.join(","))
        source.addEventListener("fetch_image", (event) => {
          let post = JSON.parse(event.data)
          let elm  = $(`[data-id=${post.id}]`)

          $('<img />', {src: post.cover}).insertBefore(elm);
          elm.remove()
        })

        source.onerror = (event) => {
          if (event.eventPhase == EventSource.CLOSED) {
            source.close();
            // TODO: Remove all loading
          }
        };
      }
    })
  }
}
