local M = {}

function M.apply(config)
    config.ssh_domains = {
        {
            name = "106编译服务器",
            remote_address = "192.168.201.106:22",
            username = "wangpeng",
            multiplexing = "None",
            -- 如果需要可以指定私钥路径
            -- ssh_option = { identityfile = "~/.ssh/id_rsa" },
        },
        {
            name = "102编译服务器",
            remote_address = "192.168.201.102:22",
            username = "wangpeng",
            multiplexing = "None",
        },
    }
end

return M
