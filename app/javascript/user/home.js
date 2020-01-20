window.IwaScraper.application = {
  initIndex(){
    let params = new URLSearchParams(window.location.search)
    let page   = parseInt(params.get('page')) || 1

    this.fetchPosts(page)
  },

  refreshNavigators(){
    let params = new URLSearchParams(window.location.search)
    let page = parseInt(params.get('page')) || 1

    $('.prev, .next').removeClass('disabled')
    $('.prev, .next').click(() => {
      $('.post-wrap').empty().append($('<div />', {class: 'loader'}))
      $('html, body').animate({ scrollTop: 0 })
    })

    if (page <= 1) {
      $('.prev').addClass('disabled')
    } else {
      $('.prev').click((e) => {
        this.refreshUrl(e, page - 1)
        this.fetchPosts(page - 1)
      })
    }

    $('.next').click((e) => {
      this.refreshUrl(e, page + 1)
      this.fetchPosts(page + 1)
    })
  },

  refreshUrl(e, request_page) {
    e.preventDefault();
    history.pushState({}, null, `?page=${request_page}`)
  },

  fetchPosts(request_page) {
    $.get( '/posts.js', { page: request_page }, () => {
      this.refreshNavigators()

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
