try {
  const savedTheme = localStorage.getItem("todo-theme")
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
  const useDarkTheme = savedTheme ? savedTheme === "dark" : prefersDark

  document.documentElement.classList.toggle("dark", useDarkTheme)
} catch (_error) {
  document.documentElement.classList.toggle(
    "dark",
    window.matchMedia("(prefers-color-scheme: dark)").matches
  )
}
