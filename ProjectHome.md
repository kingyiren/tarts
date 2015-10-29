Tarts is a **proof of concept**, **open source** P2P File Sharing AIR Application that allows users to share their files to their connected peers. It make use of the latest capabilities of Flash Player 10.1, Adobe Stratus and RTMFP protocol to allow users to share large files easily over the network

Google Groups: http://groups.google.com/group/tarts-dis/topics

## Featured List ##
  * File Sharing within a P2P Mesh - The more users are sharing the same file, the faster the download will be
  * Downloading of large files over the network - Huge files are transfer via small file chunk from peers connect via the same NetGroup.
  * Resuming of file download  - Application can be close and re-open and downloads will resume
  * Chatting with Group  - Users sharing the same file will be able to chat with all the peers in the group
  * Joining Interest Group (TBA) - Users can join ad-hoc interest groups and share files with the group


## Technical Overview ##
Tarts uses Adobe Stratus [Object Replication + RTMFP Groups](http://labs.adobe.com/technologies/stratus/rtmfpgroups.html) to replicate the files across peers. 1 File =  1 Group. Big file is broken into chunks and transmitted over the network via ByteArray.


---


![http://tarts.googlecode.com/files/screen_shot.png](http://tarts.googlecode.com/files/screen_shot.png)
