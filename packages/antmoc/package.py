from spack import *


class Antmoc(BundlePackage):
    """This bundle package is only for convenience."""

    homepage = ""

    maintainers = ['alephpiece']

    version('0.1.15')

    variant('hip', default=False, description='Enable HIP support')
    variant('mpi', default=False, description='Enable MPI support')

    depends_on('cmake@3.15:', type='build')
    depends_on('hip@3.10.0', when='+hip')
    depends_on('rocprim@3.10.0', when='+hip')
    depends_on('rocthrust@3.10.0', when='+hip')
    depends_on('mpi@3.0', when='+mpi', type=('build', 'link', 'run'))
    depends_on('fmt@6.0.0')
    depends_on('tinyxml2@7.0.0')
    depends_on('toml11@3.6.0')
    depends_on('hdf5@1.10.7 ~fortran~mpi', when='~mpi')
    depends_on('hdf5@1.10.7 ~fortran+mpi', when='+mpi')
    depends_on('googletest@1.10.0 +gmock')

