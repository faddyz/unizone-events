export function compactUrl(url) {
  try {
    const parsedUrl = new URL(url)
    return `${parsedUrl.host}${parsedUrl.pathname}`
  } catch (error) {
    return url
  }
}
