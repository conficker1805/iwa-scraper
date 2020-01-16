window.IwaScraper.application = {
  initIndex(){
    let params = new URLSearchParams(window.location.search)
    $.get( '/posts.js', {
      page: params.get('page') || 1,
      keyword: params.get('keyword')
    } )
  }
}
