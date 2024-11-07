function updatePopup() {
  chrome.storage.local.get("totalTime", (data) => {
      const totalTime = data.totalTime || 0;
      document.getElementById("totalTime").textContent = `${totalTime} seconds`;
  });
}

// 1秒ごとにデータを更新
setInterval(updatePopup, 1000);
updatePopup();
