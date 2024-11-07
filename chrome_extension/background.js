let totalTime = 0;
let activeTabUrl = null;

// アクティブタブが変更されたときにタブ情報を取得
chrome.tabs.onActivated.addListener(activeInfo => {
    chrome.tabs.get(activeInfo.tabId, tab => {
        activeTabUrl = tab.url;
    });
});

// URLが特定のページの場合、1秒ごとにカウント
setInterval(() => {
    if (activeTabUrl && (activeTabUrl.includes("x.com") || activeTabUrl.includes("twitter.com"))) {
        totalTime++;
        chrome.storage.local.set({ totalTime });
    }
}, 1000);
