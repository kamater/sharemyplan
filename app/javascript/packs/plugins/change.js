const changePlace = () => {
  const lessPlace = (currentTarget) => {
    const placeElement = document.getElementById('subscription_available_places');
      if ( parseInt(placeElement.value) > 1) {
        placeElement.value = parseInt(placeElement.value) - 1;
      }
  };

  const addPlace =(currentTarget) => {
    const maxPlace = document.getElementById('max')
    const placeElement = document.getElementById('subscription_available_places');
    console.log(maxPlace.innerHTML)

    if (parseInt(placeElement.value) < parseInt(maxPlace.innerHTML) - 1) {
      placeElement.value = parseInt(placeElement.value) + 1;
    }
  };


    const less = document.querySelector('.less_place');

    if (less) {
      less.addEventListener("click", (event) => {
         // console.log(event.currentTarget);
          lessPlace(event.currentTarget);
      });
    }


    const add = document.querySelector('.add_place');

    if (add) {
      add.addEventListener("click", (event) => {
       // console.log(event.currentTarget);
        addPlace(event.currentTarget);
      });
    }
};
export { changePlace }
