##### check ssh files
```
❯ ls -la ~/.ssh
```

##### generate the public key
```
❯ ssh-keygen -t ed25519 -C "xxx@gmail.com"
```

##### start the backend daemon as SSH private key agent, `-s` indicates output following Bourne shell(sh) format 
```
❯ eval "$(ssh-agent -s)"
```

##### add the private key to the SSH agent
```
❯ ssh-add ~/.ssh/id_ed25519
```

##### copy the content of your SSH public key file to the system clipboard
```
❯ pbcopy < ~/.ssh/id_ed25519.pub
```

##### Test the connection with github server
```
❯ ssh -T git@github.com
```

##### Change the access method from HTTPS to SSH
```
git remote -v
git remote set-url origin git@github.com:username/repo.git
```
