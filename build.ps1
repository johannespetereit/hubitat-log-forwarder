$commit = (git rev-parse HEAD)
$image = "jpetereit/hubitat-log-forwarder"
$tags = @(
  "$($image):latest"
  "$($image):$($commit)"
)
docker build . -t $tags[0]
foreach ($tag in $tags | select -Skip 1){
  docker tag $tags[0] $tag
}
foreach ($tag in $tags){
  docker push $tag
}